sap.ui.define([
    "sap/ui/core/mvc/Controller",
    "sap/ui/model/json/JSONModel"
], function (Controller, JSONModel) {
    "use strict";

    return Controller.extend("intelliinvoice.supplierchat.controller.App", {
        onInit: function () {
            const conversation = {
                id: "po-invoice-assistant",
                title: this.getOwnerComponent().getModel("i18n").getResourceBundle().getText("conversationTitle"),
                messages: []
            };

            this.getView().setModel(new JSONModel({
                profile: {
                    fullName: ""
                },
                conversations: [conversation],
                activeConversation: conversation,
                activeConversationId: conversation.id,
                draft: "",
                hasMessages: false,
                isLoading: false
            }), "chat");

            this._messageInputDelegates = ["emptyMessageInput", "messageInput"].map(inputId => {
                const delegate = {
                    onAfterRendering: function () {
                        this.byId(inputId).$()
                            .off("keydown.supplierChat")
                            .on("keydown.supplierChat", function (event) {
                                if (event.key === "Enter" && !event.shiftKey) {
                                    event.preventDefault();
                                    this.onSend();
                                }
                            }.bind(this));
                    }.bind(this)
                };

                this.byId(inputId).addEventDelegate(delegate);
                return { inputId, delegate };
            });

            this._loadProfile();
        },

        onExit: function () {
            this._messageInputDelegates.forEach(({ inputId, delegate }) => {
                const messageInput = this.byId(inputId);

                if (messageInput) {
                    messageInput.$().off("keydown.supplierChat");
                    messageInput.removeEventDelegate(delegate);
                }
            });
        },

        onConversationSelect: function (event) {
            const chatModel = this.getView().getModel("chat");
            const conversation = event.getSource().getBindingContext("chat").getObject();

            chatModel.setProperty("/activeConversation", conversation);
            chatModel.setProperty("/activeConversationId", conversation.id);
            chatModel.setProperty("/hasMessages", conversation.messages.length > 0);
        },

        onExamplePrompt: function (event) {
            this.getView().getModel("chat").setProperty("/draft", event.getSource().getText());
            this.onSend();
        },

        onSend: async function () {
            const chatModel = this.getView().getModel("chat");
            const question = chatModel.getProperty("/draft").trim();

            if (!question || chatModel.getProperty("/isLoading")) {
                return;
            }

            const messages = chatModel.getProperty("/activeConversation/messages").slice();
            const history = messages
                .filter(message =>
                    ["user", "assistant"].includes(message.role) &&
                    !message.loading &&
                    !message.error &&
                    typeof message.text === "string"
                )
                .slice(-12)
                .map(message => ({
                    role: message.role,
                    content: message.text.slice(0, 4000)
                }));

            messages.push({
                role: "user",
                text: question
            }, {
                role: "assistant",
                text: this.getOwnerComponent().getModel("i18n").getResourceBundle().getText("loadingMessage"),
                loading: true
            });

            chatModel.setProperty("/activeConversation/messages", messages);
            chatModel.setProperty("/draft", "");
            chatModel.setProperty("/hasMessages", true);
            chatModel.setProperty("/isLoading", true);
            this._scrollToLatest();

            const action = this.getView().getModel().bindContext("/ask(...)");
            action.setParameter("question", question);
            action.setParameter("history", JSON.stringify(history));

            try {
                await action.execute("$direct");
                const response = action.getBoundContext().getObject();

                messages[messages.length - 1] = {
                    role: "assistant",
                    text: response.text,
                    presentation: response.presentation || "text",
                    totalCount: response.totalCount || 0,
                    purchaseOrders: response.purchaseOrders || [],
                    invoices: response.invoices || [],
                    loading: false
                };
            } catch (error) {
                messages[messages.length - 1] = {
                    role: "assistant",
                    text: this.getOwnerComponent().getModel("i18n").getResourceBundle().getText("errorMessage"),
                    loading: false,
                    error: true
                };
            } finally {
                action.destroy();
                chatModel.setProperty("/activeConversation/messages", messages);
                chatModel.setProperty("/isLoading", false);
                this._scrollToLatest();
            }
        },

        formatInvoiceStatusText: function (status) {
            const knownStatus = {
                DRAFT: "Draft",
                IN_APPROVAL: "In approval",
                APPROVED: "Approved",
                POSTED: "Posted",
                REJECTED: "Rejected"
            }[status];

            if (knownStatus || !status) {
                return knownStatus || "";
            }

            const humanizedStatus = String(status)
                .trim()
                .replace(/([a-z0-9])([A-Z])/g, function (match, left, right) {
                    return left + " " + right;
                })
                .replace(/[_-]+/g, " ")
                .replace(/\s+/g, " ")
                .toLowerCase();

            return humanizedStatus.charAt(0).toUpperCase() +
                humanizedStatus.slice(1);
        },

        formatInvoiceStatusState: function (status) {
            return {
                DRAFT: "Information",
                IN_APPROVAL: "Warning",
                APPROVED: "Success",
                POSTED: "Success",
                REJECTED: "Error"
            }[status] || "None";
        },

        _loadProfile: async function () {
            const profileFunction = this.getView().getModel().bindContext("/getProfile(...)");

            try {
                await profileFunction.execute("$direct");
                this.getView().getModel("chat").setProperty(
                    "/profile/fullName",
                    profileFunction.getBoundContext().getProperty("fullName")
                );
            } catch (error) {
                this.getView().getModel("chat").setProperty(
                    "/profile/fullName",
                    this.getOwnerComponent().getModel("i18n").getResourceBundle().getText("defaultContactName")
                );
            } finally {
                profileFunction.destroy();
            }
        },

        _scrollToLatest: function () {
            setTimeout(function () {
                const scroller = this.byId("messageScroller");

                if (scroller) {
                    scroller.scrollTo(0, 100000, 200);
                }
            }.bind(this), 0);
        }
    });
});
