'use strict';

const fs = require('node:fs');
const path = require('node:path');
const cds = require('@sap/cds');
const {UPDATE} = cds.ql;

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
    const model = await cds.load('*');

    cds.model = cds.linked(model);

    const db = await cds.connect.to('db');
    const ManualChunks = cds.model.definitions['machinebreakdown.ManualChunks'];

    await db.tx(async tx => {
        for (const chunk of seed.chunks) {
            if (!chunk.sourceExcerpt) {
                throw new Error('Missing source excerpt for chunk ' + chunk.ID);
            }

            const affectedRows = await tx.run(
                UPDATE(ManualChunks)
                    .set({sourceExcerpt: chunk.sourceExcerpt})
                    .where({ID: chunk.ID})
            );

            if (affectedRows !== 1) {
                throw new Error('Manual chunk not found: ' + chunk.ID);
            }
        }
    });

    console.log(
        'Updated ' + seed.chunks.length +
        ' manual chunks with exact PDF source excerpts.'
    );

    await cds.shutdown();
}

main().catch(error => {
    console.error(error.message);
    process.exitCode = 1;
});
