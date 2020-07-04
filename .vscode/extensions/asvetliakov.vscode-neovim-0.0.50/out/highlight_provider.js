"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vscode_1 = require("vscode");
/**
 * Convert VIM HL attributes to vscode text decoration attributes
 * @param uiAttrs VIM UI attribute
 * @param vimSpecialColor Vim special color
 */
function vimHighlightToVSCodeOptions(uiAttrs, vimSpecialColor) {
    const options = {};
    // for absent color keys default color should be used
    options.backgroundColor = uiAttrs.background
        ? "#" + uiAttrs.background.toString(16)
        : new vscode_1.ThemeColor("editor.background");
    options.color = uiAttrs.foreground ? "#" + uiAttrs.foreground.toString(16) : new vscode_1.ThemeColor("editor.foreground");
    const specialColor = uiAttrs.special ? "#" + uiAttrs.special.toString(16) : vimSpecialColor;
    if (uiAttrs.reverse) {
        options.backgroundColor = new vscode_1.ThemeColor("editor.foreground");
        options.color = new vscode_1.ThemeColor("editor.background");
    }
    if (uiAttrs.italic) {
        options.fontStyle = "italic";
    }
    if (uiAttrs.bold) {
        options.fontWeight = "bold";
    }
    if (uiAttrs.strikethrough) {
        options.textDecoration = "line-through solid";
    }
    if (uiAttrs.underline) {
        options.textDecoration = `underline ${specialColor} solid`;
    }
    if (uiAttrs.undercurl) {
        options.textDecoration = `underline ${specialColor} wavy`;
    }
    return options;
}
function isEditorThemeColor(s) {
    return typeof s === "string" && s.startsWith("theme.");
}
function normalizeDecorationConfig(config) {
    const newConfig = Object.assign(Object.assign({}, config), { after: config.after ? Object.assign({}, config.after) : undefined, before: config.before ? Object.assign({}, config.before) : undefined });
    if (isEditorThemeColor(newConfig.backgroundColor)) {
        newConfig.backgroundColor = new vscode_1.ThemeColor(newConfig.backgroundColor.slice(6));
    }
    if (isEditorThemeColor(newConfig.borderColor)) {
        newConfig.borderColor = new vscode_1.ThemeColor(newConfig.borderColor.slice(6));
    }
    if (isEditorThemeColor(newConfig.color)) {
        newConfig.borderColor = new vscode_1.ThemeColor(newConfig.color.slice(6));
    }
    if (isEditorThemeColor(newConfig.outlineColor)) {
        newConfig.outlineColor = new vscode_1.ThemeColor(newConfig.outlineColor.slice(6));
    }
    if (isEditorThemeColor(newConfig.overviewRulerColor)) {
        newConfig.overviewRulerColor = new vscode_1.ThemeColor(newConfig.overviewRulerColor.slice(6));
    }
    if (newConfig.after) {
        if (isEditorThemeColor(newConfig.after.backgroundColor)) {
            newConfig.after.backgroundColor = new vscode_1.ThemeColor(newConfig.after.backgroundColor.slice(6));
        }
        if (isEditorThemeColor(newConfig.after.borderColor)) {
            newConfig.after.borderColor = new vscode_1.ThemeColor(newConfig.after.borderColor.slice(6));
        }
        if (isEditorThemeColor(newConfig.after.color)) {
            newConfig.after.color = new vscode_1.ThemeColor(newConfig.after.color.slice(6));
        }
    }
    if (newConfig.before) {
        if (isEditorThemeColor(newConfig.before.backgroundColor)) {
            newConfig.before.backgroundColor = new vscode_1.ThemeColor(newConfig.before.backgroundColor.slice(6));
        }
        if (isEditorThemeColor(newConfig.before.borderColor)) {
            newConfig.before.borderColor = new vscode_1.ThemeColor(newConfig.before.borderColor.slice(6));
        }
        if (isEditorThemeColor(newConfig.before.color)) {
            newConfig.before.color = new vscode_1.ThemeColor(newConfig.before.color.slice(6));
        }
    }
    return newConfig;
}
class HighlightProvider {
    constructor(conf) {
        /**
         * Current HL. key is the grid id and values is two dimension array representing rows and cols. Array may contain empty values
         */
        this.highlights = new Map();
        this.prevGridHighlightsIds = new Map();
        /**
         * Maps highlight id to highlight group name
         */
        this.highlightIdToGroupName = new Map();
        /**
         * HL group name to text decorator
         * Not all HL groups are supported now
         */
        this.highlighGroupToDecorator = new Map();
        /**
         * Store configuration per decorator
         */
        this.decoratorConfigurations = new Map();
        this.specialColor = "orange";
        /**
         * Set of ignored HL group ids. They can still be used with force flag (mainly for statusbar color decorations)
         */
        this.ignoredGroupIds = new Set();
        /**
         * List of always ignored groups
         */
        this.alwaysIgnoreGroups = [
            "Normal",
            "NormalNC",
            "NormalFloat",
            "NonText",
            "SpecialKey",
            "TermCursor",
            "TermCursorNC",
            "Cursor",
            "lCursor",
            "VisualNC",
            // "Visual",
            "Conceal",
            "CursorLine",
            "CursorLineNr",
            "ColorColumn",
            "LineNr",
            "StatusLine",
            "StatusLineNC",
            "VertSplit",
            "Title",
            "WildMenu",
            "Whitespace",
        ];
        this.configuration = conf;
        if (this.configuration.unknownHighlight !== "vim") {
            this.configuration.unknownHighlight = normalizeDecorationConfig(this.configuration.unknownHighlight);
        }
        for (const [key, config] of Object.entries(this.configuration.highlights)) {
            if (config !== "vim") {
                const options = normalizeDecorationConfig(config);
                this.configuration.highlights[key] = options;
                // precreate groups if configuration was defined
                this.createDecoratorForHighlightGroup(key, options);
            }
        }
    }
    addHighlightGroup(id, name, vimUiAttrs) {
        if (this.configuration.ignoreHighlights.includes(name) ||
            this.configuration.ignoreHighlights.find(i => i.startsWith("^") || i.endsWith("$") ? new RegExp(i).test(name) : false)) {
            this.ignoredGroupIds.add(id);
        }
        this.highlightIdToGroupName.set(id, name);
        if (this.highlighGroupToDecorator.has(name)) {
            // we have already precreated decorator
            return;
        }
        else {
            const options = this.configuration.highlights[name] || this.configuration.unknownHighlight;
            const conf = options === "vim" ? vimHighlightToVSCodeOptions(vimUiAttrs, this.specialColor) : options;
            this.createDecoratorForHighlightGroup(name, conf);
        }
    }
    getHighlightGroupName(id, force = false) {
        if (this.ignoredGroupIds.has(id) && !force) {
            return;
        }
        const name = this.highlightIdToGroupName.get(id);
        if (name && this.alwaysIgnoreGroups.includes(name)) {
            return;
        }
        return name;
    }
    getDecoratorForHighlightGroup(name) {
        let dec = this.highlighGroupToDecorator.get(name);
        if (!dec && name.endsWith("Default")) {
            dec = this.highlighGroupToDecorator.get(name.slice(0, -7));
        }
        if (!dec) {
            dec = this.highlighGroupToDecorator.get(name + "Default");
        }
        return dec;
    }
    getDecoratorOptions(decorator) {
        return this.decoratorConfigurations.get(decorator);
    }
    cleanRow(grid, row) {
        const gridHl = this.highlights.get(grid);
        if (!gridHl) {
            return;
        }
        delete gridHl[row];
    }
    processHLCellsEvent(grid, row, start, external, cells) {
        let cellHlId = 0;
        let cellIdx = start;
        if (!this.highlights.has(grid)) {
            this.highlights.set(grid, []);
        }
        const gridHl = this.highlights.get(grid);
        for (const [text, hlId, repeat] of cells) {
            // 2+bytes chars (such as chinese characters) have "" as second cell
            if (text === "") {
                continue;
            }
            if (hlId != null) {
                cellHlId = hlId;
            }
            const groupName = this.getHighlightGroupName(cellHlId, external);
            // end of the line - clean and exit
            if (text === "$" && (groupName === "NonText" || this.highlightIdToGroupName.get(cellHlId) === "NonText")) {
                if (cellIdx === 0) {
                    delete gridHl[row];
                }
                else if (gridHl[row]) {
                    gridHl[row].splice(cellIdx);
                }
                break;
            }
            for (let i = 0; i < (repeat || 1); i++) {
                if (!gridHl[row]) {
                    gridHl[row] = [];
                }
                if (groupName) {
                    gridHl[row][cellIdx] = cellHlId;
                }
                else {
                    delete gridHl[row][cellIdx];
                }
                cellIdx++;
            }
        }
    }
    shiftGridHighlights(grid, by) {
        const gridHl = this.highlights.get(grid);
        if (!gridHl) {
            return;
        }
        if (by > 0) {
            // remove clipped out rows
            for (let i = 0; i < by; i++) {
                delete gridHl[i];
            }
            // first get non empty indexes, then process, seems faster than iterating whole array
            const idxs = [];
            gridHl.forEach((_row, idx) => {
                idxs.push(idx);
            });
            // shift
            for (const idx of idxs) {
                gridHl[idx - by] = gridHl[idx];
                delete gridHl[idx];
            }
        }
        else if (by < 0) {
            // remove clipped out rows
            for (let i = 0; i < Math.abs(by); i++) {
                delete gridHl[gridHl.length - 1 - i];
            }
            const idxs = [];
            gridHl.forEach((_row, idx) => {
                idxs.push(idx);
            });
            for (const idx of idxs.reverse()) {
                gridHl[idx + Math.abs(by)] = gridHl[idx];
                delete gridHl[idx];
            }
        }
    }
    getGridHighlights(grid, topLine) {
        const result = [];
        const hlRanges = new Map();
        const gridHl = this.highlights.get(grid);
        if (gridHl) {
            // let currHlId = 0;
            let currHlName = "";
            let currHlStartRow = 0;
            let currHlEndRow = 0;
            let currHlStartCol = 0;
            let currHlEndCol = 0;
            // forEach faster than for in/of for arrays while iterating on array with empty values
            gridHl.forEach((rowHighlights, rowIdx) => {
                rowHighlights.forEach((cellHlId, cellIdx) => {
                    const cellHlName = this.highlightIdToGroupName.get(cellHlId);
                    if (cellHlName &&
                        currHlName === cellHlName &&
                        // allow to extend prev HL if on same row and next cell OR previous row and end of range is end col
                        currHlEndRow === rowIdx &&
                        currHlEndCol === cellIdx - 1) {
                        currHlEndCol = cellIdx;
                    }
                    else {
                        if (currHlName) {
                            if (!hlRanges.has(currHlName)) {
                                hlRanges.set(currHlName, []);
                            }
                            hlRanges.get(currHlName).push({
                                lineS: currHlStartRow,
                                lineE: currHlEndRow,
                                colS: currHlStartCol,
                                colE: currHlEndCol,
                            });
                            currHlName = "";
                            currHlStartCol = 0;
                            currHlEndCol = 0;
                            currHlStartRow = 0;
                            currHlEndRow = 0;
                        }
                        if (cellHlName) {
                            currHlName = cellHlName;
                            currHlStartRow = rowIdx;
                            currHlEndRow = rowIdx;
                            currHlStartCol = cellIdx;
                            currHlEndCol = cellIdx;
                        }
                    }
                });
            });
            if (currHlName) {
                if (!hlRanges.has(currHlName)) {
                    hlRanges.set(currHlName, []);
                }
                hlRanges.get(currHlName).push({
                    lineS: currHlStartRow,
                    lineE: currHlEndRow,
                    colS: currHlStartCol,
                    colE: currHlEndCol,
                });
            }
        }
        for (const [groupName, ranges] of hlRanges) {
            const decorator = this.getDecoratorForHighlightGroup(groupName);
            if (!decorator) {
                continue;
            }
            const decoratorRanges = ranges.map(r => new vscode_1.Range(topLine + r.lineS, r.colS, topLine + r.lineE, r.colE + 1));
            result.push([decorator, decoratorRanges]);
        }
        const prevHighlights = this.prevGridHighlightsIds.get(grid);
        if (prevHighlights) {
            for (const groupName of prevHighlights) {
                if (!hlRanges.has(groupName)) {
                    const decorator = this.getDecoratorForHighlightGroup(groupName);
                    if (!decorator) {
                        continue;
                    }
                    result.push([decorator, []]);
                }
            }
        }
        this.prevGridHighlightsIds.set(grid, new Set(hlRanges.keys()));
        return result;
    }
    createDecoratorForHighlightGroup(groupName, options) {
        const decorator = vscode_1.window.createTextEditorDecorationType(options);
        this.decoratorConfigurations.set(decorator, options);
        this.highlighGroupToDecorator.set(groupName, decorator);
    }
}
exports.HighlightProvider = HighlightProvider;
//# sourceMappingURL=highlight_provider.js.map