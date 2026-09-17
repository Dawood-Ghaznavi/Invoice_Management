sap.ui.define(
    [
        "sap/base/Log",
        "sap/fe/core/PageController",
        "sap/ui/core/Fragment",
        "sap/ui/model/json/JSONModel",
        "sap/m/MessageToast"
    ],
    function(Log, PageController, Fragment, JSONModel, MessageToast) {
        "use strict";

        return PageController.extend("technicianassistant.ext.view.Main", {
            onInit: function () {
                PageController.prototype.onInit.apply(this, arguments);
                this.getView().setModel(new JSONModel({
                    technicianIdentity: "",
                    selectedJobId: "",
                    activeJobId: "",
                    hasSelection: false,
                    showSelectionPrompt: true,
                    isSelectingJob: true,
                    showSelectedJob: false,
                    conversationsByJob: {},
                    activeConversation: {
                        messages: [],
                        draft: "",
                        isLoading: false
                    },
                    hasMessages: false
                }), "view");
                this.getView().setModel(new JSONModel({
                    title: "",
                    excerpt: "",
                    busy: false,
                    error: "",
                    currentPage: 1,
                    citedPage: 1,
                    totalPages: 0,
                    pageText: "",
                    zoom: 1,
                    zoomText: "100%",
                    canPrevious: false,
                    canNext: false,
                    canZoomOut: false,
                    canZoomIn: true,
                    showExcerptFallback: false
                }), "evidence");
            },

            onAfterRendering: function () {
                if (PageController.prototype.onAfterRendering) {
                    PageController.prototype.onAfterRendering.apply(
                        this,
                        arguments
                    );
                }

                if (!this._technicianIdentityRequested) {
                    const model = this.getView().getModel() ||
                        this.getOwnerComponent().getModel();

                    if (model) {
                        this._technicianIdentityRequested = true;
                        const technicianBinding = model.bindList(
                            "/Jobs",
                            null,
                            null,
                            null,
                            {$select: "assignedTechnician"}
                        );

                        technicianBinding.requestContexts(0, 1)
                            .then(contexts => {
                                const identity = contexts[0]
                                    ?.getProperty("assignedTechnician");

                                if (identity) {
                                    this.getView().getModel("view")
                                        .setProperty(
                                            "/technicianIdentity",
                                            identity
                                        );
                                }
                            })
                            .catch(error => Log.warning(
                                "Technician greeting could not be loaded",
                                error.message
                            ))
                            .finally(() => technicianBinding.destroy());
                    }
                }

                this._messageInputDelegates =
                    this._messageInputDelegates || [];

                [
                    "emptyMessageInput",
                    "messageInput"
                ].forEach(inputId => {
                    if (this._messageInputDelegates.some(entry =>
                        entry.inputId === inputId
                    )) {
                        return;
                    }

                    const messageInput = this.byId(inputId);

                    if (!messageInput) {
                        return;
                    }

                    const delegate = {
                        onAfterRendering: function () {
                            messageInput.$()
                                .off("keydown.technicianChat")
                                .on(
                                    "keydown.technicianChat",
                                    function (event) {
                                        if (event.key === "Enter" &&
                                            !event.shiftKey) {
                                            event.preventDefault();
                                            this.onSend();
                                        }
                                    }.bind(this)
                                );
                        }.bind(this)
                    };

                    messageInput.addEventDelegate(delegate);
                    delegate.onAfterRendering();
                    this._messageInputDelegates.push({inputId, delegate});
                });
            },

            onExit: function () {
                (this._messageInputDelegates || [])
                    .forEach(({inputId, delegate}) => {
                        const messageInput = this.byId(inputId);

                        if (messageInput) {
                            messageInput.$().off("keydown.technicianChat");
                            messageInput.removeEventDelegate(delegate);
                        }
                    });
                this._iEvidenceRequestID =
                    (this._iEvidenceRequestID || 0) + 1;
                this._oEvidenceAbortController?.abort();
                this._oEvidenceAbortController = null;
                this._disposeEvidenceDocument();
            },

            onJobSelectionChange: function (event) {
                const selectedItem = event.getSource().getSelectedItem();
                const stateModel = this.getView().getModel("view");

                if (!selectedItem) {
                    return;
                }

                const jobID = selectedItem.getKey();
                const conversations = {
                    ...stateModel.getProperty("/conversationsByJob")
                };
                const conversation = conversations[jobID] || {
                    messages: [],
                    draft: "",
                    isLoading: false
                };

                conversations[jobID] = conversation;
                this.getView().setBindingContext(selectedItem.getBindingContext());
                stateModel.setProperty("/conversationsByJob", conversations);
                stateModel.setProperty("/activeConversation", conversation);
                stateModel.setProperty("/selectedJobId", jobID);
                stateModel.setProperty("/activeJobId", jobID);
                stateModel.setProperty("/hasSelection", true);
                stateModel.setProperty("/showSelectionPrompt", false);
                stateModel.setProperty("/isSelectingJob", false);
                stateModel.setProperty("/showSelectedJob", true);
                stateModel.setProperty(
                    "/technicianIdentity",
                    selectedItem.getBindingContext()
                        .getProperty("assignedTechnician")
                );
                stateModel.setProperty(
                    "/hasMessages",
                    conversation.messages.length > 0
                );
            },

            onChangeJob: function () {
                const stateModel = this.getView().getModel("view");

                stateModel.setProperty("/selectedJobId", stateModel.getProperty("/activeJobId"));
                stateModel.setProperty("/isSelectingJob", true);
                stateModel.setProperty("/showSelectedJob", false);

                setTimeout(() => {
                    const selector = this.byId("jobSelector");
                    selector.focus();
                    selector.open();
                }, 0);
            },

            onCancelJobSelection: function () {
                const stateModel = this.getView().getModel("view");

                stateModel.setProperty("/selectedJobId", stateModel.getProperty("/activeJobId"));
                stateModel.setProperty("/isSelectingJob", false);
                stateModel.setProperty("/showSelectedJob", true);
            },

            onSend: async function () {
                const stateModel = this.getView().getModel("view");
                const currentConversation =
                    stateModel.getProperty("/activeConversation");
                const question = currentConversation.draft.trim();

                if (!question || currentConversation.isLoading) {
                    return;
                }

                const jobID = stateModel.getProperty("/activeJobId");
                const jobContext = this.getView().getBindingContext();

                if (!jobID || !jobContext) {
                    return;
                }

                const history = currentConversation.messages
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
                const messages = currentConversation.messages.slice();
                let conversation = {
                    ...currentConversation,
                    draft: "",
                    isLoading: true,
                    messages
                };

                messages.push({
                    role: "user",
                    text: question,
                    citations: []
                }, {
                    role: "assistant",
                    text: "",
                    citations: [],
                    loading: true
                });
                const conversations = {
                    ...stateModel.getProperty("/conversationsByJob"),
                    [jobID]: conversation
                };

                stateModel.setProperty("/conversationsByJob", conversations);
                stateModel.setProperty("/activeConversation", conversation);
                stateModel.setProperty("/hasMessages", true);
                this._scrollToLatest();

                const action = this.getView().getModel().bindContext(
                    "TechnicianAssistantService.ask(...)",
                    jobContext
                );

                action.setParameter("question", question);
                action.setParameter("history", JSON.stringify(history));

                try {
                    await action.execute("$direct");
                    const response = action.getBoundContext().getObject();

                    messages[messages.length - 1] = {
                        role: "assistant",
                        text: response.text,
                        citations: response.citations || [],
                        loading: false
                    };
                } catch (error) {
                    messages[messages.length - 1] = {
                        role: "assistant",
                        text: this.getOwnerComponent().getModel("i18n")
                            .getResourceBundle().getText("chatErrorMessage"),
                        citations: [],
                        loading: false,
                        error: true
                    };
                } finally {
                    action.destroy();
                    conversation = {
                        ...conversation,
                        messages,
                        isLoading: false
                    };

                    const conversations = {
                        ...stateModel.getProperty("/conversationsByJob"),
                        [jobID]: conversation
                    };

                    stateModel.setProperty(
                        "/conversationsByJob",
                        conversations
                    );

                    if (stateModel.getProperty("/activeJobId") === jobID) {
                        stateModel.setProperty(
                            "/activeConversation",
                            conversation
                        );
                        stateModel.setProperty(
                            "/hasMessages",
                            messages.length > 0
                        );
                        this._scrollToLatest();
                    }
                }
            },

            formatCitationLabel: function (pageNumber) {
                return this.getView().getModel("i18n").getResourceBundle()
                    .getText("manualCitation", [pageNumber || "–"]);
            },

            formatCitationTooltip: function (title, version) {
                return [title, version ? "Version " + version : ""]
                    .filter(Boolean).join(" · ");
            },

            _loadPdfJs: function () {
                if (!this._pPdfJs) {
                    sap.ui.loader.config({
                        paths: {
                            "node.process": sap.ui.require.toUrl(
                                "technicianassistant/resources/node.process"
                            )
                        }
                    });
                    this._pPdfJs = new Promise((resolve, reject) => {
                        sap.ui.require([
                            "technicianassistant/ext/util/PdfJs"
                        ], resolve, reject);
                    }).then(pdfJs => {
                        const workerPath =
                            sap.ui.require.toUrl(
                                "technicianassistant/pdfjs-worker/pdf.worker.min.mjs"
                            );

                        pdfJs.GlobalWorkerOptions.workerSrc =
                            new URL(workerPath, document.baseURI).href;
                        this._oPdfJs = pdfJs;
                        return pdfJs;
                    });
                    this._pPdfJs.catch(() => {
                        this._pPdfJs = null;
                    });
                }

                return this._pPdfJs;
            },

            onOpenCitation: async function (event) {
                const view = this.getView();
                const bundle = view.getModel("i18n").getResourceBundle();
                const evidenceModel = view.getModel("evidence");
                const source = event.getSource()
                    .getBindingContext("view")
                    ?.getObject();
                const documentID = source?.manualDocumentID;
                const pageNumber = Number(source?.pageNumber) || 1;

                if (!documentID) {
                    MessageToast.show(
                        bundle.getText("evidenceSourceUnavailable")
                    );
                    return;
                }

                const documentUrl = view.getModel().getServiceUrl() +
                    "ManualDocuments(ID=" + encodeURIComponent(documentID) +
                    ")/content/$value";
                const requestID = (this._iEvidenceRequestID || 0) + 1;

                this._iEvidenceRequestID = requestID;
                this._oEvidenceAbortController?.abort();
                this._oEvidenceAbortController = new AbortController();

                evidenceModel.setData({
                    title: [
                        source.manualTitle ||
                            bundle.getText("evidenceManual"),
                        source.manualVersion
                            ? bundle.getText(
                                "evidenceManualVersion",
                                [source.manualVersion]
                            )
                            : ""
                    ].filter(Boolean).join(" · "),
                    excerpt: source.excerpt || "",
                    busy: true,
                    error: "",
                    currentPage: pageNumber,
                    citedPage: pageNumber,
                    totalPages: 0,
                    pageText: "",
                    zoom: 1,
                    zoomText: bundle.getText(
                        "evidenceZoomIndicator",
                        [100]
                    ),
                    canPrevious: false,
                    canNext: false,
                    canZoomOut: false,
                    canZoomIn: true,
                    showExcerptFallback: false
                });

                if (!this._pEvidenceDialog) {
                    this._pEvidenceDialog = Fragment.load({
                        id: view.getId(),
                        name: "technicianassistant.ext.EvidenceViewer",
                        controller: this
                    }).then(dialog => {
                        view.addDependent(dialog);
                        return dialog;
                    });
                }

                try {
                    const dialog = await this._pEvidenceDialog;

                    if (!dialog.isOpen()) {
                        const afterOpen = new Promise(resolve =>
                            dialog.attachEventOnce("afterOpen", resolve)
                        );

                        dialog.open();
                        await afterOpen;
                    }

                    await this._disposeEvidenceDocument();

                    const response = await fetch(documentUrl, {
                        credentials: "same-origin",
                        headers: {Accept: "application/pdf"},
                        signal: this._oEvidenceAbortController.signal
                    });

                    if (!response.ok) {
                        throw new Error(
                            "Manual request failed with status " +
                            response.status
                        );
                    }

                    const pdfBytes =
                        new Uint8Array(await response.arrayBuffer());

                    if (requestID !== this._iEvidenceRequestID) {
                        return;
                    }

                    const pdfJs = await this._loadPdfJs();

                    this._oEvidenceLoadingTask =
                        pdfJs.getDocument({data: pdfBytes});
                    this._oEvidenceDocument =
                        await this._oEvidenceLoadingTask.promise;

                    if (requestID !== this._iEvidenceRequestID) {
                        return;
                    }

                    const totalPages = this._oEvidenceDocument.numPages;
                    const citedPage = Math.min(
                        Math.max(pageNumber, 1),
                        totalPages
                    );

                    evidenceModel.setProperty("/currentPage", citedPage);
                    evidenceModel.setProperty("/citedPage", citedPage);
                    evidenceModel.setProperty("/totalPages", totalPages);
                    await this._renderEvidencePage();
                } catch (error) {
                    if (error?.name !== "AbortError" &&
                        requestID === this._iEvidenceRequestID) {
                        Log.error(
                            "Unable to display the cited manual passage",
                            error?.message
                        );
                        evidenceModel.setProperty(
                            "/error",
                            bundle.getText("evidenceLoadError")
                        );
                    }
                } finally {
                    if (requestID === this._iEvidenceRequestID) {
                        evidenceModel.setProperty("/busy", false);
                    }
                }
            },

            _renderEvidencePage: async function () {
                const view = this.getView();
                const evidenceModel = view.getModel("evidence");
                const bundle = view.getModel("i18n").getResourceBundle();
                const currentPage =
                    evidenceModel.getProperty("/currentPage");
                const totalPages =
                    evidenceModel.getProperty("/totalPages");
                const citedPage =
                    evidenceModel.getProperty("/citedPage");
                const zoom = evidenceModel.getProperty("/zoom");
                const page =
                    await this._oEvidenceDocument.getPage(currentPage);
                const htmlControl = view.byId("evidencePdfHost");
                const htmlDom = htmlControl?.getDomRef();
                const pageHost = htmlDom?.matches(".evidencePageHost")
                    ? htmlDom
                    : htmlDom?.querySelector(".evidencePageHost");
                const scrollContainer = view.byId("evidenceScroll");
                const scrollDom = scrollContainer?.getDomRef();

                if (!pageHost || !scrollDom) {
                    throw new Error("The evidence viewer is not ready");
                }

                this._oEvidenceRenderTask?.cancel();

                const baseViewport = page.getViewport({scale: 1});
                const availableWidth =
                    Math.max(320, scrollDom.clientWidth - 32);
                const fitScale = availableWidth / baseViewport.width;
                const viewport =
                    page.getViewport({scale: fitScale * zoom});
                const pixelRatio =
                    Math.min(window.devicePixelRatio || 1, 2);
                const canvas = document.createElement("canvas");
                const highlightLayer = document.createElement("div");
                const context =
                    canvas.getContext("2d", {alpha: false});

                pageHost.replaceChildren();
                pageHost.style.width = viewport.width + "px";
                pageHost.style.height = viewport.height + "px";

                canvas.className = "evidencePageCanvas";
                canvas.width =
                    Math.floor(viewport.width * pixelRatio);
                canvas.height =
                    Math.floor(viewport.height * pixelRatio);
                canvas.style.width = viewport.width + "px";
                canvas.style.height = viewport.height + "px";

                highlightLayer.className = "evidenceHighlightLayer";
                pageHost.append(canvas, highlightLayer);

                this._oEvidenceRenderTask = page.render({
                    canvasContext: context,
                    viewport,
                    transform: pixelRatio === 1
                        ? null
                        : [pixelRatio, 0, 0, pixelRatio, 0, 0]
                });
                await this._oEvidenceRenderTask.promise;

                let highlightFound = false;
                let firstHighlightTop = 0;

                if (currentPage === citedPage &&
                    evidenceModel.getProperty("/excerpt")) {
                    const textContent = await page.getTextContent();
                    const pageTokens = [];

                    textContent.items.forEach((item, itemIndex) => {
                        const tokens = (item.str || "")
                            .normalize("NFKC")
                            .toLocaleLowerCase("en")
                            .match(/[\p{L}\p{N}]+/gu) || [];

                        tokens.forEach(token => {
                            pageTokens.push({token, itemIndex});
                        });
                    });

                    const excerptTokens =
                        evidenceModel.getProperty("/excerpt")
                            .normalize("NFKC")
                            .toLocaleLowerCase("en")
                            .match(/[\p{L}\p{N}]+/gu) || [];
                    let matchStart = -1;

                    if (excerptTokens.length &&
                        excerptTokens.length <= pageTokens.length) {
                        for (let start = 0;
                            start <=
                                pageTokens.length - excerptTokens.length;
                            start += 1) {
                            let matches = true;

                            for (let tokenIndex = 0;
                                tokenIndex < excerptTokens.length;
                                tokenIndex += 1) {
                                if (pageTokens[start + tokenIndex].token !==
                                    excerptTokens[tokenIndex]) {
                                    matches = false;
                                    break;
                                }
                            }

                            if (matches) {
                                matchStart = start;
                                break;
                            }
                        }
                    }

                    if (matchStart >= 0) {
                        const matchedItemIndexes = [
                            ...new Set(
                                pageTokens
                                    .slice(
                                        matchStart,
                                        matchStart + excerptTokens.length
                                    )
                                    .map(token => token.itemIndex)
                            )
                        ];

                        matchedItemIndexes.forEach(itemIndex => {
                            const item = textContent.items[itemIndex];
                            const transform = this._oPdfJs.Util.transform(
                                viewport.transform,
                                item.transform
                            );
                            const fontHeight =
                                Math.hypot(transform[2], transform[3]);
                            const left = transform[4];
                            const top = transform[5] - fontHeight;
                            const width =
                                Math.max(2, item.width * viewport.scale);
                            const highlight =
                                document.createElement("div");

                            highlight.className =
                                "evidencePassageHighlight";
                            highlight.style.left =
                                Math.max(0, left - 1) + "px";
                            highlight.style.top =
                                Math.max(0, top - 1) + "px";
                            highlight.style.width = width + 2 + "px";
                            highlight.style.height =
                                fontHeight + 2 + "px";
                            highlightLayer.appendChild(highlight);

                            if (!highlightFound ||
                                top < firstHighlightTop) {
                                firstHighlightTop = top;
                            }
                            highlightFound = true;
                        });
                    }
                }

                evidenceModel.setProperty(
                    "/showExcerptFallback",
                    currentPage === citedPage && !highlightFound
                );
                evidenceModel.setProperty(
                    "/canPrevious",
                    currentPage > 1
                );
                evidenceModel.setProperty(
                    "/canNext",
                    currentPage < totalPages
                );
                evidenceModel.setProperty("/canZoomOut", zoom > 0.75);
                evidenceModel.setProperty("/canZoomIn", zoom < 2);
                evidenceModel.setProperty(
                    "/pageText",
                    bundle.getText(
                        "evidencePageIndicator",
                        [currentPage, totalPages]
                    )
                );
                evidenceModel.setProperty(
                    "/zoomText",
                    bundle.getText(
                        "evidenceZoomIndicator",
                        [Math.round(zoom * 100)]
                    )
                );

                scrollContainer.scrollTo(
                    0,
                    highlightFound
                        ? Math.max(0, firstHighlightTop - 72)
                        : 0,
                    0
                );
            },

            _showEvidencePage: async function (pageNumber) {
                const evidenceModel =
                    this.getView().getModel("evidence");

                if (!this._oEvidenceDocument ||
                    pageNumber < 1 ||
                    pageNumber > this._oEvidenceDocument.numPages) {
                    return;
                }

                evidenceModel.setProperty("/busy", true);
                evidenceModel.setProperty("/error", "");
                evidenceModel.setProperty("/currentPage", pageNumber);

                try {
                    await this._renderEvidencePage();
                } catch (error) {
                    if (error?.name !== "RenderingCancelledException") {
                        Log.error(
                            "Unable to render the manual page",
                            error?.message
                        );
                        evidenceModel.setProperty(
                            "/error",
                            this.getView().getModel("i18n")
                                .getResourceBundle()
                                .getText("evidenceLoadError")
                        );
                    }
                } finally {
                    evidenceModel.setProperty("/busy", false);
                }
            },

            onEvidencePreviousPage: function () {
                const evidenceModel =
                    this.getView().getModel("evidence");

                return this._showEvidencePage(
                    evidenceModel.getProperty("/currentPage") - 1
                );
            },

            onEvidenceNextPage: function () {
                const evidenceModel =
                    this.getView().getModel("evidence");

                return this._showEvidencePage(
                    evidenceModel.getProperty("/currentPage") + 1
                );
            },

            onEvidenceZoomOut: function () {
                const evidenceModel =
                    this.getView().getModel("evidence");
                const zoom = Math.max(
                    0.75,
                    evidenceModel.getProperty("/zoom") - 0.25
                );

                evidenceModel.setProperty("/zoom", zoom);
                return this._showEvidencePage(
                    evidenceModel.getProperty("/currentPage")
                );
            },

            onEvidenceZoomIn: function () {
                const evidenceModel =
                    this.getView().getModel("evidence");
                const zoom = Math.min(
                    2,
                    evidenceModel.getProperty("/zoom") + 0.25
                );

                evidenceModel.setProperty("/zoom", zoom);
                return this._showEvidencePage(
                    evidenceModel.getProperty("/currentPage")
                );
            },

            onCloseEvidenceViewer: function () {
                this.byId("evidenceViewerDialog")?.close();
            },

            onEvidenceViewerAfterClose: function () {
                this._iEvidenceRequestID =
                    (this._iEvidenceRequestID || 0) + 1;
                this._oEvidenceAbortController?.abort();
                this._oEvidenceAbortController = null;
                this.getView().getModel("evidence")
                    .setProperty("/busy", false);
                this._disposeEvidenceDocument();
            },

            _disposeEvidenceDocument: async function () {
                this._oEvidenceRenderTask?.cancel();
                this._oEvidenceRenderTask = null;

                const loadingTask = this._oEvidenceLoadingTask;
                const evidenceDocument = this._oEvidenceDocument;

                this._oEvidenceLoadingTask = null;
                this._oEvidenceDocument = null;

                try {
                    if (loadingTask) {
                        await loadingTask.destroy();
                    } else if (evidenceDocument) {
                        await evidenceDocument.destroy();
                    }
                } catch (error) {
                    Log.debug(
                        "PDF.js cleanup completed with a warning",
                        error?.message
                    );
                }

                const htmlDom =
                    this.byId("evidencePdfHost")?.getDomRef();
                const pageHost =
                    htmlDom?.matches(".evidencePageHost")
                        ? htmlDom
                        : htmlDom?.querySelector(".evidencePageHost");

                pageHost?.replaceChildren();
            },

            formatJobOption: function (jobNumber, equipmentName) {
                return [jobNumber, equipmentName].filter(Boolean).join(" · ");
            },

            formatEquipmentDetails: function (equipmentID, modelName) {
                return [equipmentID, modelName].filter(Boolean).join(" · ");
            },

            formatChatContext: function (jobNumber, equipmentName) {
                return [jobNumber, equipmentName].filter(Boolean).join(" · ");
            },

            formatOptionalValue: function (value) {
                return value || "Not reported";
            },

            formatJobStatusState: function (status) {
                switch (status) {
                    case "In Progress":
                        return "Warning";
                    case "On Hold":
                        return "Error";
                    default:
                        return "Information";
                }
            },

            formatPriorityState: function (priority) {
                switch (priority) {
                    case "Critical":
                        return "Error";
                    case "High":
                        return "Warning";
                    case "Medium":
                        return "Information";
                    default:
                        return "None";
                }
            },

            formatOperatingState: function (machineStopped) {
                if (machineStopped === true) {
                    return "Reported stopped";
                }
                if (machineStopped === false) {
                    return "Reported running";
                }
                return "Status not confirmed";
            },

            formatOperatingStateState: function (machineStopped) {
                if (machineStopped === true) {
                    return "Error";
                }
                if (machineStopped === false) {
                    return "Success";
                }
                return "None";
            },

            formatReportedAt: function (reportedAt) {
                if (!reportedAt) {
                    return "Not reported";
                }

                return new Intl.DateTimeFormat(undefined, {
                    dateStyle: "medium",
                    timeStyle: "short"
                }).format(new Date(reportedAt));
            },

            formatTechnicianGreeting: function (assignedTechnician) {
                const identity = String(assignedTechnician || "").trim();
                const firstName = identity
                    .split("@")[0]
                    .split(/[.\s_-]/)[0];
                const displayName = firstName
                    ? firstName.charAt(0).toUpperCase() + firstName.slice(1)
                    : "there";
                const i18nModel =
                    this.getView().getModel("i18n") ||
                    this.getOwnerComponent().getModel("i18n");

                return i18nModel
                    ? i18nModel.getResourceBundle()
                        .getText("chatGreeting", [displayName])
                    : "Hi " + displayName + ",";
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
    }
);
