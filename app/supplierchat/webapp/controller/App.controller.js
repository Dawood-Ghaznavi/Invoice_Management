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

            this._messageInputDelegate = {
                onAfterRendering: function () {
                    this.byId("messageInput").$()
                        .off("keydown.supplierChat")
                        .on("keydown.supplierChat", function (event) {
                            if (event.key === "Enter" && !event.shiftKey) {
                                event.preventDefault();
                                this.onSend();
                            }
                        }.bind(this));
                }.bind(this)
            };
            this.byId("messageInput").addEventDelegate(this._messageInputDelegate);

            this._loadProfile();
        },

        onExit: function () {
            const messageInput = this.byId("messageInput");

            if (messageInput) {
                messageInput.$().off("keydown.supplierChat");
                messageInput.removeEventDelegate(this._messageInputDelegate);
            }
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
                messages[messages.length - 1] = {
                    role: "assistant",
                    text: action.getBoundContext().getProperty("value"),
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
