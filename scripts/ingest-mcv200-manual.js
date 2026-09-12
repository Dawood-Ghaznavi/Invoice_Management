'use strict';

const fs = require('node:fs');
const path = require('node:path');
const cds = require('@sap/cds');

async function main() {
    const projectRoot = path.resolve(__dirname, '..');
    const defaultEnvPath = path.join(projectRoot, 'default-env.json');

    if (!process.env.VCAP_SERVICES && fs.existsSync(defaultEnvPath)) {
        const localEnvironment = JSON.parse(fs.readFileSync(defaultEnvPath, 'utf8'));
        process.env.VCAP_SERVICES = JSON.stringify(localEnvironment.VCAP_SERVICES);
    }

    const seed = JSON.parse(
        fs.readFileSync(path.join(__dirname, 'data', 'mcv200-manual.json'), 'utf8')
    );
    const pdf = fs.readFileSync(path.join(projectRoot, seed.manual.fileName));
    const model = await cds.load('*');
    cds.model = cds.linked(model);

    const db = await cds.connect.to('db');
    const gpt = await cds.connect.to('GPT');
    const ManualDocuments = cds.model.definitions['machinebreakdown.ManualDocuments'];
    const ManualChunks = cds.model.definitions['machinebreakdown.ManualChunks'];

    const existingDocument = await db.run(
        SELECT.one.from(ManualDocuments)
            .columns('ID')
            .where({
                documentNumber: seed.manual.documentNumber,
                version: seed.manual.version
            })
    );

    if (existingDocument) {
        throw new Error(
            'Manual ' + seed.manual.documentNumber + ' version ' +
            seed.manual.version + ' already exists. Create a new version instead of replacing it.'
        );
    }

    const embeddingResponse = await gpt.post('/v1/embeddings', {
        model: seed.embeddingModel,
        input: seed.chunks.map(chunk => chunk.content)
    });
    const embeddings = [...(embeddingResponse.data || [])]
        .sort((left, right) => left.index - right.index);

    if (embeddings.length !== seed.chunks.length ||
        embeddings.some(result =>
            !Array.isArray(result.embedding) ||
            result.embedding.length !== seed.embeddingDimensions ||
            !result.embedding.every(Number.isFinite)
        )) {
        throw new Error('OpenAI returned an invalid or unexpected embedding response');
    }

    await db.tx(async tx => {
        await tx.run(
            INSERT.into(ManualDocuments).entries({
                ...seed.manual,
                content: pdf
            })
        );

        await tx.run(
            INSERT.into(ManualChunks).entries(
                seed.chunks.map((chunk, index) => ({
                    ...chunk,
                    document_ID: seed.manual.ID,
                    embedding: JSON.stringify(embeddings[index].embedding)
                }))
            )
        );
    });

    console.log(
        'Inserted ' + seed.manual.documentNumber + ' version ' +
        seed.manual.version + ' with ' + seed.chunks.length +
        ' chunks using ' + seed.embeddingModel + ' (' +
        seed.embeddingDimensions + ' dimensions).'
    );

    await cds.shutdown();
}

main().catch(error => {
    console.error(error.message);
    process.exitCode = 1;
});
