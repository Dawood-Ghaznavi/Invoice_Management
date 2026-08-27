/**
 * Stateless supplier chat endpoint used by the future portal UI.
 * Business data is read through SupplierMCPService so CAP remains
 * responsible for supplier isolation.
 */
@path: 'supplier-chat'
@requires: 'authenticated-user'
service SupplierChatService {

    /**
     * Answers a supplier question using the read-only Supplier MCP tools.
     */
    action ask(question: LargeString) returns LargeString;

}
