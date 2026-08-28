/**
 * Stateless supplier chat endpoint used by the future portal UI.
 * Business data is read through SupplierMCPService so CAP remains
 * responsible for supplier isolation.
 */
@path: 'supplier-chat'
@requires: 'authenticated-user'
service SupplierChatService {

    type SupplierProfile {
        fullName : String(150);
    }

    /**
     * Returns the display name of the authenticated supplier contact.
     */
    function getProfile() returns SupplierProfile;

    /**
     * Answers a supplier question using the read-only Supplier MCP tools.
     */
    action ask(
        question : LargeString,
        history  : LargeString
    ) returns LargeString;

}
