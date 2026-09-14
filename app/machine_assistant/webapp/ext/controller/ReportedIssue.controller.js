sap.ui.define([
    "sap/base/Log",
    "sap/ui/core/library",
    "sap/ui/core/Fragment",
    "sap/ui/core/mvc/ControllerExtension",
    "sap/ui/model/Filter",
    "sap/ui/model/FilterOperator",
    "sap/ui/model/Sorter",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (Log, coreLibrary, Fragment, ControllerExtension, Filter, FilterOperator, Sorter, JSONModel, MessageToast) {
    "use strict";

    const {ValueState} = coreLibrary;

    return ControllerExtension.extend("machineassistant.ext.controller.ReportedIssue", {
        override: {
            onInit: function () {
                this.base.getView().setModel(new JSONModel({
                    searchText: "",
                    equipment: null,
                    equipmentValueState: ValueState.None,
                    symptomsValueState: ValueState.None,
                    busy: false,
                    error: "",
                    guidanceWarnings: [],
                    guidancePrimary: [],
                    hasGuidanceWarnings: false,
                    hasGuidancePrimary: false
                }), "reportedIssue");
                this.base.getView().setModel(new JSONModel({
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
            routing: {
                onAfterBinding: async function (oBindingContext) {
                    const oIssueModel = this.base.getView().getModel("reportedIssue");

                    oIssueModel.setProperty("/equipmentValueState", ValueState.None);
                    oIssueModel.setProperty("/symptomsValueState", ValueState.None);
                    oIssueModel.setProperty("/error", "");
                    oIssueModel.setProperty("/guidanceWarnings", []);
                    oIssueModel.setProperty("/guidancePrimary", []);
                    oIssueModel.setProperty("/hasGuidanceWarnings", false);
                    oIssueModel.setProperty("/hasGuidancePrimary", false);

                    try {
                        const sEquipmentID = await oBindingContext.requestProperty("equipment_equipmentID");

                        if (!sEquipmentID) {
                            oIssueModel.setProperty("/searchText", "");
                            oIssueModel.setProperty("/equipment", null);
                            return;
                        }

                        const oEquipmentBinding = oBindingContext.getModel().bindList(
                            "/Equipment",
                            null,
                            null,
                            [new Filter("equipmentID", FilterOperator.EQ, sEquipmentID)],
                            {$expand: "model"}
                        );
                        const aEquipmentContexts = await oEquipmentBinding.requestContexts(0, 1);
                        const oEquipment = aEquipmentContexts[0]?.getObject();

                        if (oEquipment) {
                            oIssueModel.setProperty("/searchText", oEquipment.name || oEquipment.equipmentID);
                            oIssueModel.setProperty("/equipment", {
                                equipmentID: oEquipment.equipmentID,
                                name: oEquipment.name,
                                modelName: oEquipment.model?.name || oEquipment.model_modelID || "",
                                location: oEquipment.location
                            });
                        }

                        if (await oBindingContext.requestProperty("guidanceIsCurrent")) {
                            await this._loadGuidancePresentation(oBindingContext);
                        }
                    } catch (oError) {
                        Log.error("Unable to load the selected equipment", oError?.message);
                    }
                }
            }
        },

        _loadGuidancePresentation: async function (oReportContext) {
            const oModel = oReportContext.getModel();
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const oBundle = this.base.getView().getModel("i18n").getResourceBundle();
            const oItemsBinding = oModel.bindList(
                "guidanceItems",
                oReportContext,
                [new Sorter("sequence", false)],
                null,
                {$select: "ID,type,sequence,text,source_ID"}
            );
            const oSourcesBinding = oModel.bindList(
                "guidanceSources",
                oReportContext,
                [new Sorter("relevanceScore", true)],
                null,
                {
                    $select: "ID,manualDocument_ID,pageNumber,excerpt,relevanceScore",
                    $expand: "manualDocument($select=ID,documentNumber,title,version,fileName)"
                }
            );
            const [aItemContexts, aSourceContexts, sFaultCode, vMachineStopped] = await Promise.all([
                oItemsBinding.requestContexts(0, 100),
                oSourcesBinding.requestContexts(0, 100),
                oReportContext.requestProperty("faultCode"),
                oReportContext.requestProperty("machineStopped")
            ]);
            const mSourcesByID = new Map(aSourceContexts.map(oContext => {
                const oSource = oContext.getObject();
                return [oSource.ID, oSource];
            }));
            const mTypePresentation = {
                Prerequisite: {
                    label: oBundle.getText("guidanceTypePrerequisite"),
                    state: "Warning",
                    icon: "sap-icon://pending"
                },
                "Possible Cause": {
                    label: oBundle.getText("guidanceTypePossibleCause"),
                    state: "None",
                    icon: "sap-icon://inspection"
                },
                "Recommended Check": {
                    label: oBundle.getText("guidanceTypeRecommendedCheck"),
                    state: "None",
                    icon: "sap-icon://activity-items"
                },
                General: {
                    label: oBundle.getText("guidanceTypeGeneral"),
                    state: "None",
                    icon: "sap-icon://hint"
                }
            };
            const aItems = aItemContexts.map(oContext => {
                const oItem = oContext.getObject();
                const oSource = mSourcesByID.get(oItem.source_ID) || {};
                const oDocument = oSource.manualDocument || {};
                const oPresentation = mTypePresentation[oItem.type] || mTypePresentation.General;
                const iPageNumber = oSource.pageNumber;

                return {
                    type: oItem.type,
                    typeLabel: oItem.type === "Warning"
                        ? oBundle.getText("guidanceTypeWarning")
                        : oPresentation.label,
                    state: oItem.type === "Warning" ? "Error" : oPresentation.state,
                    icon: oItem.type === "Warning" ? "sap-icon://alert" : oPresentation.icon,
                    text: oItem.text,
                    sourceDocumentID: oSource.manualDocument_ID,
                    pageNumber: iPageNumber,
                    excerpt: oSource.excerpt,
                    documentTitle:
                        oDocument.title || oDocument.fileName || oBundle.getText("equipmentManual"),
                    documentVersion: oDocument.version || "",
                    citationLabel: oBundle.getText(
                        "manualCitation",
                        [iPageNumber || oBundle.getText("unknownPage")]
                    ),
                    citationTooltip: [
                        oDocument.title || oDocument.fileName || oBundle.getText("equipmentManual"),
                        oDocument.version
                            ? oBundle.getText("manualVersion", [oDocument.version])
                            : ""
                    ].filter(Boolean).join(" · ")
                };
            });
            const bFaultCodeAndOperatingStateProvided =
                Boolean(sFaultCode?.trim()) &&
                (vMachineStopped === true || vMachineStopped === false);
            const aWarnings = aItems.filter(oItem =>
                ["Warning", "Prerequisite"].includes(oItem.type)
            ).filter(oItem =>
                !bFaultCodeAndOperatingStateProvided || !(
                    /\brecord\b/i.test(oItem.text) &&
                    /\b(?:displayed\s+)?(?:fault\s+)?code\b/i.test(oItem.text) &&
                    /\b(?:operating state|machine state|stopped|running)\b/i.test(oItem.text)
                )
            );
            const aPossibleCauses = aItems.filter(oItem =>
                oItem.type === "Possible Cause"
            );
            const aRecommendedChecks = aItems.filter(oItem =>
                oItem.type === "Recommended Check"
            );
            const aPrimary = [
                ...aPossibleCauses.slice(0, 1),
                ...aRecommendedChecks.slice(0, 2)
            ];

            if (!aPrimary.length) {
                aPrimary.push(...aItems.filter(oItem =>
                    !["Warning", "Prerequisite"].includes(oItem.type)
                ).slice(0, 2));
            }

            oIssueModel.setProperty("/guidanceWarnings", aWarnings);
            oIssueModel.setProperty("/guidancePrimary", aPrimary);
            oIssueModel.setProperty("/hasGuidanceWarnings", aWarnings.length > 0);
            oIssueModel.setProperty("/hasGuidancePrimary", aPrimary.length > 0);
        },

        onEquipmentSuggest: function (oEvent) {
            const sValue = oEvent.getParameter("suggestValue");
            const oBinding = oEvent.getSource().getBinding("suggestionRows");
            const aFilters = [new Filter("isActive", FilterOperator.EQ, true)];

            if (sValue) {
                aFilters.push(new Filter({
                    filters: [
                        new Filter("name", FilterOperator.Contains, sValue),
                        new Filter("equipmentID", FilterOperator.Contains, sValue),
                        new Filter("location", FilterOperator.Contains, sValue)
                    ],
                    and: false
                }));
            }

            oBinding.filter(aFilters);
        },

        onEquipmentSelected: async function (oEvent) {
            const oSelectedRow = oEvent.getParameter("selectedRow");

            if (!oSelectedRow) {
                return;
            }

            const oEquipment = oSelectedRow.getBindingContext().getObject();
            const oReportContext = oEvent.getSource().getBindingContext();
            const oIssueModel = this.base.getView().getModel("reportedIssue");

            try {
                await oReportContext.setProperty("equipment_equipmentID", oEquipment.equipmentID);
                oIssueModel.setProperty("/searchText", oEquipment.name || oEquipment.equipmentID);
                oIssueModel.setProperty("/equipment", {
                    equipmentID: oEquipment.equipmentID,
                    name: oEquipment.name,
                    modelName: oEquipment.model?.name || oEquipment.model_modelID || "",
                    location: oEquipment.location
                });
                oIssueModel.setProperty("/equipmentValueState", ValueState.None);
                oIssueModel.setProperty("/error", "");
            } catch (oError) {
                Log.error("Unable to select equipment", oError?.message);
                oIssueModel.setProperty("/error", "The equipment selection could not be saved. Please try again.");
            }
        },

        onEquipmentLiveChange: async function (oEvent) {
            const sValue = oEvent.getParameter("value");
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const oSelectedEquipment = oIssueModel.getProperty("/equipment");

            oIssueModel.setProperty("/searchText", sValue);
            oIssueModel.setProperty("/equipmentValueState", ValueState.None);

            if (oSelectedEquipment && sValue !== oSelectedEquipment.name) {
                try {
                    await oEvent.getSource().getBindingContext().setProperty("equipment_equipmentID", null);
                    oIssueModel.setProperty("/equipment", null);
                } catch (oError) {
                    Log.error("Unable to clear equipment", oError?.message);
                }
            }
        },

        onMachineStoppedChange: async function (oEvent) {
            const sKey = oEvent.getSource().getSelectedKey();
            const vMachineStopped = sKey === "yes" ? true : sKey === "no" ? false : null;

            try {
                await oEvent.getSource().getBindingContext().setProperty("machineStopped", vMachineStopped);
            } catch (oError) {
                Log.error("Unable to save the reported operating state", oError?.message);
            }
        },

        onFindGuidance: async function (oEvent) {
            const oButton = oEvent.getSource();
            const oReportContext = oButton.getBindingContext();
            const oIssueModel = this.base.getView().getModel("reportedIssue");
            const [sEquipmentID, sSymptoms] = await Promise.all([
                oReportContext.requestProperty("equipment_equipmentID"),
                oReportContext.requestProperty("observedSymptoms")
            ]);

            oIssueModel.setProperty(
                "/equipmentValueState",
                sEquipmentID ? ValueState.None : ValueState.Error
            );
            oIssueModel.setProperty(
                "/symptomsValueState",
                sSymptoms && sSymptoms.trim() ? ValueState.None : ValueState.Error
            );

            if (!sEquipmentID || !sSymptoms || !sSymptoms.trim()) {
                oIssueModel.setProperty("/error", "Select equipment and describe the observed symptoms before finding guidance.");
                return;
            }

            oIssueModel.setProperty("/busy", true);
            oIssueModel.setProperty("/error", "");

            try {
                await this.base.editFlow.invokeAction("BreakdownService.findGuidance", {
                    contexts: [oReportContext],
                    model: oReportContext.getModel(),
                    skipParameterDialog: true
                });
                await oReportContext.requestSideEffects([
                    {$PropertyPath: "guidanceIsCurrent"},
                    {$PropertyPath: "reportedConcern"},
                    {$PropertyPath: "missingInformation"},
                    {$PropertyPath: "suggestedShortDescription"},
                    {$PropertyPath: "suggestedDetailedDescription"},
                    {$PropertyPath: "suggestionAdoptedAt"},
                    {$NavigationPropertyPath: "guidanceItems"},
                    {$NavigationPropertyPath: "guidanceSources"}
                ]);
                await this._loadGuidancePresentation(oReportContext);
                MessageToast.show("Guidance is ready for review.");
            } catch (oError) {
                Log.error("Unable to retrieve guidance", oError?.message);
                oIssueModel.setProperty("/error", "Guidance could not be retrieved. Please review the inputs and try again.");
            } finally {
                oIssueModel.setProperty("/busy", false);
            }
        },

        onUseSuggestedReport: async function (oEvent) {
            const oButton = oEvent.getSource();
            const oReportContext = oButton.getBindingContext();

            oButton.setBusy(true);

            try {
                await this.base.editFlow.invokeAction("BreakdownService.useSuggestedReport", {
                    contexts: [oReportContext],
                    model: oReportContext.getModel(),
                    skipParameterDialog: true
                });
                await oReportContext.requestSideEffects([
                    {"$PropertyPath": "shortDescription"},
                    {"$PropertyPath": "detailedDescription"},
                    {"$PropertyPath": "suggestionAdoptedAt"}
                ]);
                MessageToast.show(
                    this.base.getView().getModel("i18n").getResourceBundle().getText("guidanceAppliedMessage")
                );
            } catch (oError) {
                Log.error("Unable to use the suggested report", oError?.message);
            } finally {
                oButton.setBusy(false);
            }
        },

        _loadPdfJs: function () {
            if (!this._pPdfJs) {
                this._pPdfJs = new Promise((resolve, reject) => {
                    sap.ui.require([
                        "machineassistant/ext/util/PdfJs"
                    ], resolve, reject);
                }).then(oPdfJs => {
                    oPdfJs.GlobalWorkerOptions.workerSrc =
                        sap.ui.require.toUrl("pdfjs-dist/build/pdf.worker.min.mjs");
                    this._oPdfJs = oPdfJs;
                    return oPdfJs;
                });
            }

            return this._pPdfJs;
        },

        onOpenGuidanceSource: async function (oEvent) {
            const oView = this.base.getView();
            const oBundle = oView.getModel("i18n").getResourceBundle();
            const oEvidenceModel = oView.getModel("evidence");
            const oSource = oEvent.getSource()
                .getBindingContext("reportedIssue")
                ?.getObject();
            const sDocumentID = oSource?.sourceDocumentID;
            const iPageNumber = Number(oSource?.pageNumber) || 1;

            if (!sDocumentID) {
                MessageToast.show(oBundle.getText("guidanceSourceUnavailable"));
                return;
            }

            const sDocumentUrl = oView.getModel().getServiceUrl() +
                "ManualDocuments(ID=" + encodeURIComponent(sDocumentID) +
                ")/content/$value";
            const iRequestID = (this._iEvidenceRequestID || 0) + 1;

            this._iEvidenceRequestID = iRequestID;
            this._oEvidenceAbortController?.abort();
            this._oEvidenceAbortController = new AbortController();

            oEvidenceModel.setData({
                title: [
                    oSource.documentTitle || oBundle.getText("equipmentManual"),
                    oSource.documentVersion
                        ? oBundle.getText("manualVersion", [oSource.documentVersion])
                        : ""
                ].filter(Boolean).join(" · "),
                excerpt: oSource.excerpt || "",
                busy: true,
                error: "",
                currentPage: iPageNumber,
                citedPage: iPageNumber,
                totalPages: 0,
                pageText: "",
                zoom: 1,
                zoomText: oBundle.getText("evidenceZoomIndicator", [100]),
                canPrevious: false,
                canNext: false,
                canZoomOut: false,
                canZoomIn: true,
                showExcerptFallback: false
            });

            if (!this._pEvidenceDialog) {
                this._pEvidenceDialog = Fragment.load({
                    id: oView.getId(),
                    name: "machineassistant.ext.EvidenceViewer",
                    controller: this
                }).then(oDialog => {
                    oView.addDependent(oDialog);
                    return oDialog;
                });
            }

            try {
                const oDialog = await this._pEvidenceDialog;

                if (!oDialog.isOpen()) {
                    const pAfterOpen = new Promise(resolve =>
                        oDialog.attachEventOnce("afterOpen", resolve)
                    );
                    oDialog.open();
                    await pAfterOpen;
                }

                await this._disposeEvidenceDocument();

                const oResponse = await fetch(sDocumentUrl, {
                    credentials: "same-origin",
                    headers: {Accept: "application/pdf"},
                    signal: this._oEvidenceAbortController.signal
                });

                if (!oResponse.ok) {
                    throw new Error("Manual request failed with status " + oResponse.status);
                }

                const aPdfBytes = new Uint8Array(await oResponse.arrayBuffer());

                if (iRequestID !== this._iEvidenceRequestID) {
                    return;
                }

                const oPdfJs = await this._loadPdfJs();

                this._oEvidenceLoadingTask = oPdfJs.getDocument({data: aPdfBytes});
                this._oEvidenceDocument = await this._oEvidenceLoadingTask.promise;

                if (iRequestID !== this._iEvidenceRequestID) {
                    return;
                }

                const iTotalPages = this._oEvidenceDocument.numPages;
                const iCitedPage = Math.min(Math.max(iPageNumber, 1), iTotalPages);

                oEvidenceModel.setProperty("/currentPage", iCitedPage);
                oEvidenceModel.setProperty("/citedPage", iCitedPage);
                oEvidenceModel.setProperty("/totalPages", iTotalPages);
                await this._renderEvidencePage();
            } catch (oError) {
                if (oError?.name !== "AbortError" &&
                    iRequestID === this._iEvidenceRequestID) {
                    Log.error("Unable to display the cited manual passage", oError?.message);
                    oEvidenceModel.setProperty("/error", oBundle.getText("evidenceLoadError"));
                }
            } finally {
                if (iRequestID === this._iEvidenceRequestID) {
                    oEvidenceModel.setProperty("/busy", false);
                }
            }
        },

        _renderEvidencePage: async function () {
            const oView = this.base.getView();
            const oEvidenceModel = oView.getModel("evidence");
            const oBundle = oView.getModel("i18n").getResourceBundle();
            const iCurrentPage = oEvidenceModel.getProperty("/currentPage");
            const iTotalPages = oEvidenceModel.getProperty("/totalPages");
            const iCitedPage = oEvidenceModel.getProperty("/citedPage");
            const fZoom = oEvidenceModel.getProperty("/zoom");
            const oPage = await this._oEvidenceDocument.getPage(iCurrentPage);
            const oHtmlControl = oView.byId("evidencePdfHost");
            const oHtmlDom = oHtmlControl?.getDomRef();
            const oPageHost = oHtmlDom?.matches(".evidencePageHost")
                ? oHtmlDom
                : oHtmlDom?.querySelector(".evidencePageHost");
            const oScrollContainer = oView.byId("evidenceScroll");
            const oScrollDom = oScrollContainer?.getDomRef();

            if (!oPageHost || !oScrollDom) {
                throw new Error("The evidence viewer is not ready");
            }

            this._oEvidenceRenderTask?.cancel();

            const oBaseViewport = oPage.getViewport({scale: 1});
            const iAvailableWidth = Math.max(320, oScrollDom.clientWidth - 32);
            const fFitScale = iAvailableWidth / oBaseViewport.width;
            const oViewport = oPage.getViewport({scale: fFitScale * fZoom});
            const fPixelRatio = Math.min(window.devicePixelRatio || 1, 2);
            const oCanvas = document.createElement("canvas");
            const oHighlightLayer = document.createElement("div");
            const oContext = oCanvas.getContext("2d", {alpha: false});

            oPageHost.replaceChildren();
            oPageHost.style.width = oViewport.width + "px";
            oPageHost.style.height = oViewport.height + "px";

            oCanvas.className = "evidencePageCanvas";
            oCanvas.width = Math.floor(oViewport.width * fPixelRatio);
            oCanvas.height = Math.floor(oViewport.height * fPixelRatio);
            oCanvas.style.width = oViewport.width + "px";
            oCanvas.style.height = oViewport.height + "px";

            oHighlightLayer.className = "evidenceHighlightLayer";
            oPageHost.append(oCanvas, oHighlightLayer);

            this._oEvidenceRenderTask = oPage.render({
                canvasContext: oContext,
                viewport: oViewport,
                transform: fPixelRatio === 1
                    ? null
                    : [fPixelRatio, 0, 0, fPixelRatio, 0, 0]
            });
            await this._oEvidenceRenderTask.promise;

            let bHighlightFound = false;
            let fFirstHighlightTop = 0;

            if (iCurrentPage === iCitedPage && oEvidenceModel.getProperty("/excerpt")) {
                const oTextContent = await oPage.getTextContent();
                const aPageTokens = [];

                oTextContent.items.forEach((oItem, iItemIndex) => {
                    const aTokens = (oItem.str || "")
                        .normalize("NFKC")
                        .toLocaleLowerCase("en")
                        .match(/[\p{L}\p{N}]+/gu) || [];

                    aTokens.forEach(sToken => {
                        aPageTokens.push({token: sToken, itemIndex: iItemIndex});
                    });
                });

                const aExcerptTokens = oEvidenceModel.getProperty("/excerpt")
                    .normalize("NFKC")
                    .toLocaleLowerCase("en")
                    .match(/[\p{L}\p{N}]+/gu) || [];
                let iMatchStart = -1;

                if (aExcerptTokens.length && aExcerptTokens.length <= aPageTokens.length) {
                    for (let iStart = 0;
                        iStart <= aPageTokens.length - aExcerptTokens.length;
                        iStart += 1) {
                        let bMatches = true;

                        for (let iToken = 0; iToken < aExcerptTokens.length; iToken += 1) {
                            if (aPageTokens[iStart + iToken].token !== aExcerptTokens[iToken]) {
                                bMatches = false;
                                break;
                            }
                        }

                        if (bMatches) {
                            iMatchStart = iStart;
                            break;
                        }
                    }
                }

                if (iMatchStart >= 0) {
                    const aMatchedItemIndexes = [
                        ...new Set(
                            aPageTokens
                                .slice(iMatchStart, iMatchStart + aExcerptTokens.length)
                                .map(oToken => oToken.itemIndex)
                        )
                    ];

                    aMatchedItemIndexes.forEach(iItemIndex => {
                        const oItem = oTextContent.items[iItemIndex];
                        const aTransform = this._oPdfJs.Util.transform(
                            oViewport.transform,
                            oItem.transform
                        );
                        const fFontHeight = Math.hypot(aTransform[2], aTransform[3]);
                        const fLeft = aTransform[4];
                        const fTop = aTransform[5] - fFontHeight;
                        const fWidth = Math.max(2, oItem.width * oViewport.scale);
                        const oHighlight = document.createElement("div");

                        oHighlight.className = "evidencePassageHighlight";
                        oHighlight.style.left = Math.max(0, fLeft - 1) + "px";
                        oHighlight.style.top = Math.max(0, fTop - 1) + "px";
                        oHighlight.style.width = fWidth + 2 + "px";
                        oHighlight.style.height = fFontHeight + 2 + "px";
                        oHighlightLayer.appendChild(oHighlight);

                        if (!bHighlightFound || fTop < fFirstHighlightTop) {
                            fFirstHighlightTop = fTop;
                        }
                        bHighlightFound = true;
                    });
                }
            }

            oEvidenceModel.setProperty(
                "/showExcerptFallback",
                iCurrentPage === iCitedPage && !bHighlightFound
            );
            oEvidenceModel.setProperty("/canPrevious", iCurrentPage > 1);
            oEvidenceModel.setProperty("/canNext", iCurrentPage < iTotalPages);
            oEvidenceModel.setProperty("/canZoomOut", fZoom > 0.75);
            oEvidenceModel.setProperty("/canZoomIn", fZoom < 2);
            oEvidenceModel.setProperty(
                "/pageText",
                oBundle.getText("evidencePageIndicator", [iCurrentPage, iTotalPages])
            );
            oEvidenceModel.setProperty(
                "/zoomText",
                oBundle.getText("evidenceZoomIndicator", [Math.round(fZoom * 100)])
            );

            oScrollContainer.scrollTo(
                0,
                bHighlightFound ? Math.max(0, fFirstHighlightTop - 72) : 0,
                0
            );
        },

        _showEvidencePage: async function (iPageNumber) {
            const oEvidenceModel = this.base.getView().getModel("evidence");

            if (!this._oEvidenceDocument ||
                iPageNumber < 1 ||
                iPageNumber > this._oEvidenceDocument.numPages) {
                return;
            }

            oEvidenceModel.setProperty("/busy", true);
            oEvidenceModel.setProperty("/error", "");
            oEvidenceModel.setProperty("/currentPage", iPageNumber);

            try {
                await this._renderEvidencePage();
            } catch (oError) {
                if (oError?.name !== "RenderingCancelledException") {
                    Log.error("Unable to render the manual page", oError?.message);
                    oEvidenceModel.setProperty(
                        "/error",
                        this.base.getView().getModel("i18n").getResourceBundle()
                            .getText("evidenceLoadError")
                    );
                }
            } finally {
                oEvidenceModel.setProperty("/busy", false);
            }
        },

        onEvidencePreviousPage: function () {
            const oEvidenceModel = this.base.getView().getModel("evidence");

            return this._showEvidencePage(
                oEvidenceModel.getProperty("/currentPage") - 1
            );
        },

        onEvidenceNextPage: function () {
            const oEvidenceModel = this.base.getView().getModel("evidence");

            return this._showEvidencePage(
                oEvidenceModel.getProperty("/currentPage") + 1
            );
        },

        onEvidenceZoomOut: function () {
            const oEvidenceModel = this.base.getView().getModel("evidence");
            const fZoom = Math.max(0.75, oEvidenceModel.getProperty("/zoom") - 0.25);

            oEvidenceModel.setProperty("/zoom", fZoom);
            return this._showEvidencePage(oEvidenceModel.getProperty("/currentPage"));
        },

        onEvidenceZoomIn: function () {
            const oEvidenceModel = this.base.getView().getModel("evidence");
            const fZoom = Math.min(2, oEvidenceModel.getProperty("/zoom") + 0.25);

            oEvidenceModel.setProperty("/zoom", fZoom);
            return this._showEvidencePage(oEvidenceModel.getProperty("/currentPage"));
        },

        onCloseEvidenceViewer: function () {
            this.base.getView().byId("evidenceViewerDialog")?.close();
        },

        onEvidenceViewerAfterClose: function () {
            this._iEvidenceRequestID = (this._iEvidenceRequestID || 0) + 1;
            this._oEvidenceAbortController?.abort();
            this._oEvidenceAbortController = null;
            this.base.getView().getModel("evidence").setProperty("/busy", false);
            this._disposeEvidenceDocument();
        },

        _disposeEvidenceDocument: async function () {
            this._oEvidenceRenderTask?.cancel();
            this._oEvidenceRenderTask = null;

            const oLoadingTask = this._oEvidenceLoadingTask;
            const oDocument = this._oEvidenceDocument;

            this._oEvidenceLoadingTask = null;
            this._oEvidenceDocument = null;

            try {
                if (oLoadingTask) {
                    await oLoadingTask.destroy();
                } else if (oDocument) {
                    await oDocument.destroy();
                }
            } catch (oError) {
                Log.debug("PDF.js cleanup completed with a warning", oError?.message);
            }

            const oHtmlDom = this.base.getView().byId("evidencePdfHost")?.getDomRef();
            const oPageHost = oHtmlDom?.matches(".evidencePageHost")
                ? oHtmlDom
                : oHtmlDom?.querySelector(".evidencePageHost");

            oPageHost?.replaceChildren();
        },

        onDismissError: function () {
            this.base.getView().getModel("reportedIssue").setProperty("/error", "");
        }
    });
});
