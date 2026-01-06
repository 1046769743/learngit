// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { Log } from "../../FrameWork/Log";
import { GameMgr } from "../../Module/Game/GameMgr";
import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { UIManager } from "../../FrameWork/UIManager";
import { PrefabDefine } from "../../FrameWork/PrefabDefine";
import ItemWord from "./ItemWord";
import ItemChar from "./ItemChar";
import ItemSelectEffect from "./ItemSelectEffect";
import { Tools } from "../../Common/Tools";
import ItemSelectShow from "./ItemSelectShow";
import { CollectEffectType, EffectManager } from "../../Common/EffectManager";
import { TargetNodeKeys } from "../../FrameWork/TargetNodeKeys";
import { EventCenter } from "../../FrameWork/EventCenter";
import { EventName } from "../../Common/EventName";
import UserDataMgr from "../../Module/UserData/UserDataMgr";
import { NativeApi } from "../../Platform/Android/NativeApi";
import AdMgr, { AdType, ModuleType } from "../../Module/AdModel/AdMgr";
import ItemCombo from "../Item/ItemCombo";
import { SOUND_NAME, SoundManager } from "../../Module/Audio/SoundManager";
import ClientConfig from "../../Data/ClientConfig";
import { GuideMgr, GuideType } from "../../Module/Guide/GuideMgr";
import ComboRoot from "../Item/ComboRoot";
import PopupSequenceConfig, { PopupSequenceType } from "../../Module/PopupSequence/PopupSequenceConfig";
import PopupSequenceMgr from "../../Module/PopupSequence/PopupSequenceMgr";

const { ccclass, property } = cc._decorator;

/**
 * 游戏状态枚举
 */
enum GameState {
    Playing = "playing",
    Completed = "completed"
}

/**
 * 单词信息接口
 */
interface WordInfo {
    startRow: number;
    startCol: number;
    direction: cc.Vec2;
    cells: cc.Vec2[];
    length: number;
}

/**
 * 目标词布局配置
 */
interface WordLayoutConfig {
    maxPerRow: number;
    totalRows: number;
    itemSpacing: number;
}

@ccclass
export default class GameUI extends cc.Component {
    // ========== UI节点引用 ==========
    @property(cc.Node)
    private targetGroup: cc.Node = null;

    @property(cc.Label)
    private laLevel: cc.Label = null;

    @property(cc.Node)
    private gridGroup: cc.Node = null;

    @property(cc.Node)
    private grideBgNode: cc.Node = null;

    @property(cc.Node)
    private selectEffectGroup: cc.Node = null;

    @property(cc.Node)
    private showSelectGroup: cc.Node = null;

    @property(cc.Prefab)
    private itemWordPrefab: cc.Prefab = null;

    @property(cc.Prefab)
    private itemCharPrefab: cc.Prefab = null;

    @property(cc.Prefab)
    private itemSelectEffectPrefab: cc.Prefab = null;

    @property(cc.Button)
    private btnHitWord: cc.Button = null;

    @property(cc.Button)
    private btnRotation: cc.Button = null;

    @property(cc.Label)
    private laTipNumber: cc.Label = null;

    @property(cc.Node)
    private nodeAdTipNode: cc.Node = null;

    @property(cc.Node)
    private nodeTipNode: cc.Node = null;

    @property(ComboRoot)
    private comboRoot: ComboRoot = null;

    @property(cc.Node)
    private maskNode: cc.Node = null;

    @property(cc.Node)
    public nodeGuide: cc.Node = null;

    @property(cc.Node)
    public nodeGuideHit: cc.Node = null;

    // ========== 常量配置 ==========
    private readonly GRID_WIDTH = 640;
    private readonly GRID_HEIGHT = 640;
    private readonly SPACING = 5;
    private readonly ROW_SPACING = 50;
    private readonly MOVE_CHECK_INTERVAL = 5;

    // 8个搜索方向：按照Tools.getStandardDirection的顺序
    private readonly SEARCH_DIRECTIONS = [
        cc.v2(1, 0),   // 右
        cc.v2(1, 1),   // 右上
        cc.v2(0, 1),   // 上
        cc.v2(-1, 1),  // 左上
        cc.v2(-1, 0),  // 左
        cc.v2(-1, -1), // 左下
        cc.v2(0, -1),  // 下
        cc.v2(1, -1)   // 右下
    ];

    // 6个色值
    private readonly COLOR_VALUES: cc.Color[] = [
        cc.color(255, 87, 87, 255),   // 红色
        cc.color(255, 165, 0, 255),   // 橙色
        cc.color(255, 215, 0, 255),   // 金黄色
        cc.color(76, 209, 55, 255),   // 绿色
        cc.color(52, 152, 219, 255),  // 蓝色
        cc.color(155, 89, 182, 255)   // 紫色
    ];

    // ========== 游戏数据 ==========
    private currentGameData: LevelGameData = null;
    private gameState: GameState = GameState.Playing;

    // ========== 网格数据 ==========
    private gridCells: cc.Node[][] = [];
    private wordItems: cc.Node[] = [];
    private cellSize: number = 0;

    // ========== 选择状态 ==========
    private isSelecting: boolean = false;
    private selectedCells: cc.Vec2[] = [];
    private startCell: cc.Vec2 = null;
    private allTargetCells: cc.Vec2[] = [];
    private moveCheckCount: number = 0;
    private currentDirection: cc.Vec2 = null;

    // ========== 效果对象 ==========
    private showSelectItem: ItemSelectShow = null;
    private currentSelectEffect: ItemSelectEffect = null;
    private currentTipEffect: ItemSelectEffect = null;
    private currentFoundEffects: ItemSelectEffect[] = [];
    private unusedColors: cc.Color[] = [];
    private tempColors: cc.Color[] = [];
    private usedColors: cc.Color[] = [];
    private currentColor: cc.Color = null;
    private currentSounds: string[] = [];

    // ========== 旋转状态 ==========
    private isRotating: boolean = false;

    // ========== 提示动画状态 ==========
    private isPlayingHintAnimation: boolean = false;

    // ========== 生命周期 ==========
    start() {
        EventCenter.dispatchEvent(EventName.EnterGameUI);
        this.initEvent();
        this.onUpdateTipNumber();
        this.initGame();
        this.updateBulbActive();
    }

    onDestroy() {
        this.recycleWordItems();
        this.recycleGridCells();
        this.onDisposeEvent();
    }

    public setGuide1GuideNodeSizeAndPosition(targetWord: string) {
        if (!this.currentGameData || !this.currentGameData.words || this.currentGameData.words.length === 0) {
            Log.Error("setGuide1GuideNodeSizeAndPosition - 游戏数据或单词数组为空");
            return;
        }

        // 查找单词在网格中的位置信息
        const wordInfo = this.findWordInGrid(targetWord);
        if (!wordInfo) {
            Log.Error("setGuide1GuideNodeSizeAndPosition - 未找到单词 " + targetWord + " 的位置信息");
            return;
        }

        Log.Debug("setGuide1GuideNodeSizeAndPosition - 单词信息:", "startRow:", wordInfo.startRow, "startCol:", wordInfo.startCol, "direction:", wordInfo.direction, "length:", wordInfo.length);

        // 获取单元格大小
        const cellSize = this.getCellSize();
        const { startX, startY } = this.getGridStartPosition(cellSize);

        // 计算起始单元格的位置
        const startCellX = startX + wordInfo.startCol * (cellSize + this.SPACING);
        const startCellY = startY + wordInfo.startRow * (cellSize + this.SPACING);

        // 计算结束单元格的位置
        const endRow = wordInfo.startRow + wordInfo.direction.y * (wordInfo.length - 1);
        const endCol = wordInfo.startCol + wordInfo.direction.x * (wordInfo.length - 1);
        const endCellX = startX + endCol * (cellSize + this.SPACING);
        const endCellY = startY + endRow * (cellSize + this.SPACING);

        // 计算nodeGuide的位置（起始和结束单元格的中心点）
        const guideX = (startCellX + endCellX) / 2;
        const guideY = (startCellY + endCellY) / 2;

        // // 计算nodeGuide的大小
        // let guideWidth, guideHeight;
        // if (wordInfo.direction.x !== 0 && wordInfo.direction.y !== 0) {
        //     // 对角线方向
        //     const dx = Math.abs(endCellX - startCellX);
        //     const dy = Math.abs(endCellY - startCellY);
        //     // 对角线长度（使用勾股定理）
        //     const diagonalLength = Math.sqrt(dx * dx + dy * dy) + cellSize;
        //     // 对于对角线，使用一个能覆盖对角线区域的矩形
        //     // 宽度和高度都设置为对角线长度，或者使用一个更大的矩形来确保覆盖
        //     guideWidth = diagonalLength;
        //     guideHeight = diagonalLength;
        // } else if (wordInfo.direction.x !== 0) {
        //     // 水平方向（向左或向右）
        //     guideWidth = Math.abs(endCellX - startCellX) + cellSize;
        //     guideHeight = cellSize;
        // } else {
        //     // 垂直方向（向上或向下）
        //     guideWidth = cellSize;
        //     guideHeight = Math.abs(endCellY - startCellY) + cellSize;
        // }

        // 设置nodeGuide的位置和大小
        if (this.nodeGuide) {
            if (wordInfo.direction.x !== 0 && wordInfo.direction.y !== 0) {
                this.nodeGuide.setPosition(guideX, guideY);
                this.nodeGuide.width = Math.sqrt(460 * 460);
                this.nodeGuide.height = 120;
                let angle = Math.atan2(wordInfo.direction.y, wordInfo.direction.x) * 180 / Math.PI;
                this.nodeGuide.angle = angle;
            } else {
                this.nodeGuide.width = 460;
                this.nodeGuide.height = 120;
                this.nodeGuide.setPosition(guideX, guideY);
                this.nodeGuide.angle = 0;
            }

            // Log.Debug("setGuide1GuideNodeSizeAndPosition - 设置完成",
            //     "position:", `(${guideX.toFixed(2)}, ${guideY.toFixed(2)})`,
            //     "size:", `${guideWidth.toFixed(2)} x ${guideHeight.toFixed(2)}`,
            //     "cellSize:", cellSize);
        } else {
            Log.Error("setGuide1GuideNodeSizeAndPosition - nodeGuide节点为空");
        }
    }

    // ========== 初始化 ==========
    private initEvent() {
        this.btnHitWord.node.on('click', this.onBtnHitWordClick, this);
        this.btnRotation.node.on('click', this.onBtnRotationClick, this);

        UIManager.Instance.registerTargetNode(TargetNodeKeys.ICON_HIT, this.btnHitWord.node);
        EventCenter.on(EventName.UpdateTipNumber, this.onUpdateTipNumber, this);
        EventCenter.on(EventName.UseHitEvent, this.onUseHitEvent, this);
        EventCenter.on(EventName.GuideSwipeComplete, this.onGuideSwipeComplete, this);
        EventCenter.on(EventName.PopRewardClose, this.onPopRewardClose, this);
    }

    private onPopRewardClose() {
        let passLevel = GameMgr.Instance.isAllWordsFound();
        if (passLevel) {
            this.onLevelComplete();
        }
    }

    private onUpdateTipNumber() {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            this.nodeAdTipNode.active = false;
            this.nodeTipNode.active = false;
            return;
        }

        let hitNum = UserDataMgr.Instance.tipNumber;
        this.laTipNumber.string = hitNum.toString();
        if (hitNum <= 0) {
            this.nodeAdTipNode.active = true;
            this.nodeTipNode.active = false;
        } else {
            this.nodeAdTipNode.active = false;
            this.nodeTipNode.active = true;
            this.laTipNumber.string = hitNum.toString();
        }
    }

    private updateBulbActive() {
        let gameLevel = GameMgr.Instance.getCurrentLevel();
        let bulbShowLevel = ClientConfig.globalConfig.BulbShowLevel.Value;
        if (gameLevel >= parseInt(bulbShowLevel)) {
            this.btnHitWord.node.active = true;
        } else {
            this.btnHitWord.node.active = false;
        }

        let rotateShowLevel = ClientConfig.globalConfig.RotateShowLevel.Value;
        if (gameLevel >= parseInt(rotateShowLevel)) {
            this.btnRotation.node.active = true;
        } else {
            this.btnRotation.node.active = false;
        }
    }

    private onUseHitEvent() {
        this.onBtnHitWordClick();
    }

    private initGame() {
        this.isRotating = false;
        GameMgr.Instance.setGameUI(this);
        this.showSelectItem = this.showSelectGroup.getComponent(ItemSelectShow);
        this.currentGameData = GameMgr.Instance.getCurrentWordSearchGameData();
        let hitNum = UserDataMgr.Instance.tipNumber;
        if (hitNum <= 0) {
            this.laTipNumber.string = "AD";
        } else {
            this.laTipNumber.string = hitNum.toString();
        }
        this.startLevel(this.currentGameData.levelId);
    }

    // ========== 按钮事件 ==========
    public onBtnHitWordClick(isShowClickSound: boolean = true) {
        Log.Debug('onBtnHitWordClick');
        if (isShowClickSound) {
            SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        }
        if (this.isRotating) {
            Log.Debug("当前正在旋转");
            return;
        }

        if (this.isPlayingHintAnimation) return;

        // 打点
        NativeApi.instance.buryPoint("BulbUse");
        NativeApi.instance.buryPoint("ToolUseLevel");

        // 清理之前的提示
        this.recycleTipEffect();

        const unfinishedWords = GameMgr.Instance.getUnfinishedWords();
        if (unfinishedWords.length === 0) return;

        let isSuccess = UserDataMgr.Instance.subTipNumber();
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (!isSuccess && !isWhiteBao) {
            Log.Debug("提示道具不足,看广告");
            AdMgr.Instance.showAd(ModuleType.PropsHit, AdType.BulbReward);
            return;
        }

        SoundManager.Instance.PlaySound(SOUND_NAME.BulbHit);

        this.onUpdateTipNumber();

        let color = this.consumeOneColor(false);
        const wordInfo: WordInfo = this.findWordInGrid(unfinishedWords[0]);
        if (wordInfo) {
            // 第一版 提示可以完成的单词
            // this.showTipEffect(wordInfo, color);

            // 第二版 直接完成单词
            // this.selectedCells = wordInfo.cells;
            // this.currentColor = color;
            // const { wordIndex, matchedWord } = this.findMatchedWord(unfinishedWords[0]);
            // this.onWordFound(wordIndex, matchedWord);

            // 第三版 模拟滑动动画效果
            this.playHintAnimation(wordInfo, color);
        } else {
            // 需要判断是否过关
            let passLevel = GameMgr.Instance.isAllWordsFound();
            if (passLevel) {
                UIManager.Instance.open(PrefabDefine.PopGameWin);
            }
        }
    }

    private onBtnRotationClick() {
        Log.Debug('onBtnRotationClick');
        SoundManager.Instance.PlaySound(SOUND_NAME.BtnClick);
        if (this.isRotating) return;
        if (this.isPlayingHintAnimation) return;
        if (!this.currentGameData) {
            Log.Error('无法旋转网格：游戏数据不存在');
            return;
        }
        this.playRotationAnimation();
    }

    // ========== 关卡管理 ==========
    public startLevel(levelId: number) {
        this.cleanupCurrentLevel();

        if (!GameMgr.Instance.startWordSearchLevel(levelId)) return;
        EventCenter.dispatchEvent(EventName.LevelFinish);

        this.currentGameData = GameMgr.Instance.getCurrentWordSearchGameData();
        if (!this.currentGameData) return;

        // 打点
        let esData = { level: levelId, wordAmonut: this.currentGameData.words.length }
        NativeApi.instance.buryPoint("LevelBeigin", JSON.stringify(esData));

        this.maskNode.active = false;
        this.gameState = GameState.Playing;
        this.currentSounds = [];
        this.showSelectItem.hide();
        this.comboRoot.reset();
        this.gridGroup.parent.angle = 0;
        this.initColorValues();
        this.updateCurrentLevel();
        this.createTargetWords();
        this.createGrid();
        this.createCompletedWordsEffect();

        this.updateBulbActive();

        // 引导
        this.onGuideShow(levelId);

        this.checkAndShowPopups();
    }

    private checkAndShowPopups(): void {
        const popupSequence = PopupSequenceConfig.Instance.getSequenceConfig(PopupSequenceType.BeforeStartGame);
        if (popupSequence && popupSequence.length > 0) {
            PopupSequenceMgr.Instance.showSequence(popupSequence);
        }
    }

    private onGuideShow(levelId: number) {
        let guideStep = UserDataMgr.Instance.guideStep;
        if (guideStep == 5 && levelId == 2) {
            GuideMgr.Instance.changeStep(GuideType.NewUser, 10);
        } else if (guideStep == 11 && levelId == 2) {
            GuideMgr.Instance.changeStep(GuideType.NewUser, 11);
        }
    }

    private initColorValues() {
        this.usedColors = [];
        this.tempColors = [];
        this.unusedColors = this.COLOR_VALUES.slice();
        this.unusedColors.sort(() => Math.random() - 0.5);
    }

    private updateCurrentLevel() {
        Log.Debug('updateCurrentLevel: ' + this.currentGameData.levelId);
        this.laLevel.string = "Level " + this.currentGameData.levelId;
    }

    private onLevelComplete() {
        if (this.gameState !== GameState.Playing) return;
        this.gameState = GameState.Completed;
        this.maskNode.active = true;
        // 播放过关动画
        cc.tween(this.grideBgNode)
            .to(0.35, { opacity: 0 })
            .start();

        cc.tween(this.gridGroup)
            .delay(0.3)
            .to(0.55, { angle: -180, scale: 0.2, opacity: 1 }, { easing: cc.easing.sineIn })
            .call(() => {
                this.showGameWinPopup();
            })
            .start();
    }

    public showGameWinPopup() {
        let isWhiteBao = UserDataMgr.Instance.isWhiteBao;
        if (isWhiteBao) {
            GameMgr.Instance.startNextLevel();
            return;
        }
        const popupSequence = PopupSequenceConfig.Instance.getLevelFinishSequence();
        if (popupSequence && popupSequence.length > 0) {
            PopupSequenceMgr.Instance.showSequence(popupSequence);
        }
    }

    // ========== UI创建 ==========
    private createTargetWords() {
        this.recycleWordItems();

        const words = this.currentGameData.words;
        const layoutConfig = this.getWordLayoutConfig(words.length);

        words.forEach((word, i) => {
            const wordItem = this.createWordItem(word, i, layoutConfig);
            this.wordItems.push(wordItem);
        });
    }

    private createWordItem(word: string, index: number, config: WordLayoutConfig): cc.Node {
        const wordItem = ObjectPoolManager.instance.getNode(this.itemWordPrefab);
        this.targetGroup.addChild(wordItem);

        const itemWord = wordItem.getComponent(ItemWord);
        if (itemWord) {
            itemWord.updateWord(word);
        }

        const position = this.calculateWordItemPosition(index, config);
        wordItem.setPosition(position.x, position.y);

        return wordItem;
    }

    private getWordLayoutConfig(wordCount: number): WordLayoutConfig {
        if (wordCount <= 3) {
            return { maxPerRow: 3, totalRows: 1, itemSpacing: 200 };
        } else if (wordCount <= 6) {
            return { maxPerRow: 3, totalRows: 2, itemSpacing: 200 };
        } else {
            return { maxPerRow: 4, totalRows: 2, itemSpacing: 160 };
        }
    }

    private calculateWordItemPosition(index: number, config: WordLayoutConfig): cc.Vec2 {
        const row = Math.floor(index / config.maxPerRow);
        const col = index % config.maxPerRow;
        const wordsInRow = Math.min(config.maxPerRow, this.currentGameData.words.length - row * config.maxPerRow);

        // 计算X位置（居中）
        let x = 0;
        if (wordsInRow === 1) x = 0;
        else if (wordsInRow === 2) x = (col - 0.5) * config.itemSpacing;
        else if (wordsInRow === 3) x = (col - 1) * config.itemSpacing;
        else if (wordsInRow === 4) x = (col - 1.5) * config.itemSpacing;

        // 计算Y位置
        const y = config.totalRows === 1 ? 0 :
            (row === 0 ? this.ROW_SPACING / 2 : -this.ROW_SPACING / 2);

        return cc.v2(x, y);
    }

    private createGrid() {
        this.recycleGridCells();
        this.gridGroup.active = true;
        this.gridGroup.opacity = 255;
        this.gridGroup.scale = 1;
        this.gridGroup.angle = 0;
        this.grideBgNode.active = true;
        this.grideBgNode.opacity = 255;
        this.grideBgNode.scale = 1;
        this.grideBgNode.angle = 0;

        const { rows, cols } = this.currentGameData.gridSize;
        const grid = this.currentGameData.grid;
        const cellSize = this.getCellSize();
        const { startX, startY } = this.getGridStartPosition(cellSize);

        for (let row = 0; row < rows; row++) {
            this.gridCells[row] = [];
            for (let col = 0; col < cols; col++) {
                const cellNode = this.createGridCell(grid[row][col], cellSize);
                this.gridCells[row][col] = cellNode;

                const x = startX + col * (cellSize + this.SPACING);
                const y = startY + row * (cellSize + this.SPACING);
                cellNode.setPosition(x, y);
            }
        }

        this.addGridTouchEvents();
    }

    private createGridCell(letter: string, cellSize: number): cc.Node {
        const cellNode = ObjectPoolManager.instance.getNode(this.itemCharPrefab);
        this.gridGroup.addChild(cellNode);
        cellNode.setContentSize(cellSize, cellSize);
        cellNode.angle = 0;

        const itemChar = cellNode.getComponent(ItemChar) as ItemChar;
        if (itemChar) {
            itemChar.updateChar(letter, this.cellSize);
        }

        return cellNode;
    }

    private createCompletedWordsEffect() {
        const foundWords = this.currentGameData.foundWords;
        foundWords.forEach(word => {
            let color = this.consumeOneColor();
            this.highlightFoundWord(word, color);
            const wordIndex = this.currentGameData.words.indexOf(word);
            this.updateWordItem(wordIndex, true);
        });
    }

    // ========== 网格触摸事件 ==========

    private isCanTouchGrid() {
        return !this.isRotating;
    }

    private addGridTouchEvents() {
        this.gridGroup.on(cc.Node.EventType.TOUCH_START, (event) => {
            this.onGridTouchStart(event);
        }, this);

        this.gridGroup.on(cc.Node.EventType.TOUCH_MOVE, (event) => {
            this.onGridTouchMove(event);
        }, this);

        this.gridGroup.on(cc.Node.EventType.TOUCH_END, (event) => {
            this.onGridTouchEnd(event);
        }, this);

        this.gridGroup.on(cc.Node.EventType.TOUCH_CANCEL, (event) => {
            this.onGridTouchCancel(event);
        }, this);
    }

    private onGridTouchStart(event: cc.Event.EventTouch) {
        if (!this.isCanTouchGrid()) return;
        this.recycleTipEffect();
        const pos = this.gridGroup.convertToNodeSpaceAR(event.getLocation());
        const cellPos = this.getCellPositionFromWorldPos(pos);
        if (cellPos) {
            this.onCellTouchStart(cellPos.row, cellPos.col);
        }
    }

    private onGridTouchMove(event: cc.Event.EventTouch) {
        const worldPos = event.getLocation();

        // 检查是否在引导模式下，如果是则检查点是否在GuideUI范围内
        const guideUI = GuideMgr.Instance.guideUI;
        if (guideUI && guideUI.node.active) {
            // 检查触摸点是否在GuideUI的swipeNode范围内
            if (!guideUI.isPositionInSwipeBounds(worldPos)) {
                Log.Debug("GameUI onGridTouchMove - 触摸点不在GuideUI范围内，忽略事件");
                return;
            }
        }

        const pos = this.gridGroup.convertToNodeSpaceAR(worldPos);
        this.onCellTouchMove(pos);
    }

    private onGridTouchEnd(event: cc.Event.EventTouch) {
        this.onCellTouchEnd();
    }

    private onGridTouchCancel(event: cc.Event.EventTouch) {
        this.onCellTouchCancel();
    }

    private removeGridTouchEvents() {
        this.gridGroup.off(cc.Node.EventType.TOUCH_START);
        this.gridGroup.off(cc.Node.EventType.TOUCH_MOVE);
        this.gridGroup.off(cc.Node.EventType.TOUCH_END);
        this.gridGroup.off(cc.Node.EventType.TOUCH_CANCEL);
    }

    private onCellTouchStart(row: number, col: number) {
        Log.Debug('onCellTouchStart: ', row, col + " ----------------------------------- ");
        if (this.isSelecting) return;
        if (this.isPlayingHintAnimation) return;

        this.clearSelection();
        this.isSelecting = true;
        this.startCell = cc.v2(row, col);
        this.selectedCells = [];
        this.currentDirection = null;

        this.currentColor = this.consumeOneColor(false);
        Log.Debug('点击开始的单词颜色: ', this.currentColor);

        this.addSelectedCell(row, col);

        this.createSelectEffect(row, col);

        this.showSelectItem.updateShow([this.startCell], this.currentColor);

        this.playSlideSound();
    }

    private addSelectedCell(row: number, col: number) {
        const pos = cc.v2(row, col);
        this.selectedCells.push(pos);
        if (this.allTargetCells.indexOf(pos) === -1) {
            this.allTargetCells.push(pos);
        }
        this.updateCellSelection(row, col, true);
    }

    private onCellTouchMove(localPos: cc.Vec2) {
        if (!this.isSelecting) return;
        if (this.isPlayingHintAnimation) return;

        this.moveCheckCount++;
        if (this.moveCheckCount >= this.MOVE_CHECK_INTERVAL) {
            this.updateSelectedCellsFromPosition(localPos);
            this.moveCheckCount = 0;
        }
    }

    private onCellTouchEnd() {
        if (!this.isSelecting) return;
        // 如果正在播放提示动画，忽略触摸结束事件
        if (this.isPlayingHintAnimation) return;
        Log.Debug("onCellTouchEnd ----------------------------------- ");
        this.validateSelectedWord();
        this.clearSelection();
        this.isSelecting = false;
    }

    private onCellTouchCancel() {
        Log.Debug("onCellTouchCancel ----------------------------------- ");
        if (!this.isSelecting) return;
        // 如果正在播放提示动画，忽略触摸取消事件
        if (this.isPlayingHintAnimation) return;
        this.validateSelectedWord();
        this.clearSelection();
        this.isSelecting = false;
    }

    // ========== 播放声音 ==========
    // 播放滑动声音
    private playSlideSound() {
        let selectedCellsCount = this.selectedCells.length;
        let soundCount = this.currentSounds.length;
        if (selectedCellsCount == soundCount) {
            return;
        }

        if (soundCount < selectedCellsCount) {
            let soundName = SoundManager.Instance.GetSoundNameByCount(soundCount + 1);
            if (soundName) {
                this.currentSounds.push(soundName);
                SoundManager.Instance.PlaySound(soundName);
            }
        }

        if (soundCount > selectedCellsCount) {
            let soundName = this.currentSounds[soundCount - 1];

            // 只保留 0 到 selectedCellsCount 的元素
            this.currentSounds = this.currentSounds.slice(0, selectedCellsCount);
            SoundManager.Instance.PlaySound(soundName);
        }
    }

    // ========== 选择逻辑 ==========
    private updateSelectedCellsFromPosition(movePos: cc.Vec2) {
        const startRow = this.startCell.x;
        const startCol = this.startCell.y;
        const startPos = this.gridCells[startRow][startCol].getPosition();

        const direction = Tools.getStandardDirection(startPos, movePos);
        this.currentDirection = direction;

        // 计算最大步数
        const maxSteps = this.calculateMaxSteps(this.startCell, direction);

        // 计算有效距离（限制在棋盘边缘内）
        const actualDistance = this.calculateValidDistance(startPos, movePos, startRow, startCol, direction, maxSteps);

        const cellCount = this.calculateCellCount(direction, actualDistance);

        this.currentSelectEffect.setLengthAndDirection(actualDistance, direction);
        this.updateSelectedCells(startRow, startCol, direction, cellCount);
        this.showSelectItem.updateShow(this.selectedCells, this.currentColor);
        this.playSlideSound();
    }

    /**
     * 计算有效距离（如果超出棋盘，则计算到边缘的距离）
     * @param startPos 起始位置（世界坐标）
     * @param movePos 移动到的位置（世界坐标）
     * @param startRow 起始行
     * @param startCol 起始列
     * @param direction 方向
     * @param maxSteps 最大步数
     * @returns 有效距离
     */
    private calculateValidDistance(startPos: cc.Vec2, movePos: cc.Vec2, startRow: number, startCol: number, direction: cc.Vec2, maxSteps: number): number {
        const originalDistance = cc.Vec2.distance(movePos, startPos);

        // 如果没有方向（原地不动），直接返回0
        if (direction.x === 0 && direction.y === 0) {
            return 0;
        }

        // 计算边缘单元格的位置
        const edgeRow = startRow + direction.y * (maxSteps - 1);
        const edgeCol = startCol + direction.x * (maxSteps - 1);

        // 获取边缘单元格的位置
        const edgeCell = this.gridCells[edgeRow]?.[edgeCol];
        if (!edgeCell) {
            return originalDistance;
        }

        const edgeCellPos = edgeCell.getPosition();
        const distanceToEdge = cc.Vec2.distance(startPos, edgeCellPos) + this.getCellSize() / 4;

        // 返回较小的距离（限制在棋盘边缘内）
        return Math.min(originalDistance, distanceToEdge) + this.getCellSize() / 4;
    }

    /**
     * 计算从起始点沿指定方向的最大步长
     * @param startCell 起始单元格 (row, col)
     * @param direction 方向向量 (direction.x对应列，direction.y对应行)
     * @returns 最大步数
     */
    private calculateMaxSteps(startCell: cc.Vec2, direction: cc.Vec2): number {
        if (!this.currentGameData || (direction.x === 0 && direction.y === 0)) {
            return 1;
        }

        const { rows, cols } = this.currentGameData.gridSize;
        const row = startCell.x;
        const col = startCell.y;

        let maxStepsInRow = Infinity;
        let maxStepsInCol = Infinity;

        // 计算行方向的最大步数
        if (direction.y > 0) {
            // 向上：最多到 rows - 1
            maxStepsInRow = rows - row;
        } else if (direction.y < 0) {
            // 向下：最多到 0
            maxStepsInRow = row + 1;
        }

        // 计算列方向的最大步数
        if (direction.x > 0) {
            // 向右：最多到 cols - 1
            maxStepsInCol = cols - col;
        } else if (direction.x < 0) {
            // 向左：最多到 0
            maxStepsInCol = col + 1;
        }

        // 取两个方向的最小值
        const maxSteps = Math.min(maxStepsInRow, maxStepsInCol);

        return maxSteps;
    }

    private calculateCellCount(direction: cc.Vec2, distance: number): number {
        if (direction.x === 0 && direction.y === 0) {
            return 1;
        }

        let cellSize = this.getCellSize();
        if (direction.x !== 0 && direction.y !== 0) {
            cellSize = Math.sqrt(cellSize * cellSize + cellSize * cellSize);
        }

        return Math.floor(distance / cellSize) + 1;
    }

    private updateSelectedCells(startRow: number, startCol: number, direction: cc.Vec2, count: number) {
        this.clearCurrentSelection();
        for (let i = 0; i < count; i++) {
            const newRow = startRow + direction.y * i;
            const newCol = startCol + direction.x * i;

            if (this.isValidCell(newRow, newCol)) {
                this.selectedCells.push(cc.v2(newRow, newCol));
                this.updateCellSelection(newRow, newCol, true);
            }
        }
    }

    private clearCurrentSelection() {
        this.selectedCells.forEach(cell => {
            this.updateCellSelection(cell.x, cell.y, false);
        });
        this.selectedCells = [];
    }

    private clearSelection() {
        this.clearCurrentSelection();
        this.startCell = null;
        this.recycleSelectEffect();
        this.recycleTipEffect();
        this.currentSounds = [];
        this.currentDirection = null;
    }

    private updateCellSelection(row: number, col: number, selected: boolean) {
        const cellNode = this.gridCells[row]?.[col];
        if (!cellNode) return;

        const itemChar = cellNode.getComponent(ItemChar);
        if (itemChar) {
            itemChar.setSelected(selected);
        }
    }

    // 消耗一个颜色 并返回
    private consumeOneColor(isUsed: boolean = false): cc.Color {
        // 如果未使用的颜色用完，则将临时给未使用，临时置空
        if (this.unusedColors.length === 0) {
            this.unusedColors = this.tempColors;
            this.tempColors = [];
        }
        let color = this.unusedColors.shift();
        if (isUsed) {
            this.usedColors.push(color);
        } else {
            this.tempColors.push(color);
        }
        return color;
    }

    // ========== 单词验证 ==========
    private validateSelectedWord() {
        Log.Debug("validateSelectedWord");
        if (this.selectedCells.length === 0) return;

        const selectedWord = this.getSelectedWord();
        const { wordIndex, matchedWord } = this.findMatchedWord(selectedWord);

        if (wordIndex !== -1) {
            this.onWordFound(wordIndex, matchedWord);
        } else {
            this.onWordNotFound();
        }
    }

    private getSelectedWord(): string {
        return this.selectedCells.map(cell => {
            return this.currentGameData.grid[cell.x][cell.y];
        }).join('');
    }

    private findMatchedWord(selectedWord: string): { wordIndex: number, matchedWord: string } {
        const targetWords = this.currentGameData.words;
        let wordIndex = targetWords.indexOf(selectedWord);
        let matchedWord = selectedWord;

        // 尝试倒序查找
        if (wordIndex === -1) {
            const reversedWord = selectedWord.split('').reverse().join('');
            wordIndex = targetWords.indexOf(reversedWord);
            if (wordIndex !== -1) {
                matchedWord = reversedWord;
            }
        }

        return { wordIndex, matchedWord };
    }

    private async onWordFound(wordIndex: number, word: string) {
        let newFound = GameMgr.Instance.onFoundWord(word);
        if (!newFound) {
            this.onWordFounded();
            return;
        }
        SoundManager.Instance.PlaySound(SOUND_NAME.WordRight);
        let color = this.currentColor;
        Log.Debug('找到的单词颜色: ', color);
        if (!color) {
            color = this.consumeOneColor(true);
        }
        this.showSelectItem.hide();
        this.highlightFoundWord(word, color);

        let guideStep = UserDataMgr.Instance.guideStep;
        if (guideStep == 1 && word == "FUN") {
            GuideMgr.Instance.onStepEnd();
            NativeApi.instance.buryPoint("Guide01");
        } else if (guideStep == 2 && word == "AIR") {
            GuideMgr.Instance.onStepEnd();
            NativeApi.instance.buryPoint("Guide02");
        } else if (guideStep == 3 && word == "CAT") {
            GuideMgr.Instance.onStepEnd();
            NativeApi.instance.buryPoint("Guide03");
        }

        let hSelectedCells = this.selectedCells;

        let passLevel = GameMgr.Instance.isAllWordsFound();
        // 播放收集字母动画
        let wordItemPos = this.wordItems[wordIndex].getPosition();
        wordItemPos = this.targetGroup.convertToWorldSpaceAR(wordItemPos);
        wordItemPos = cc.v2(wordItemPos.x - Math.floor(hSelectedCells.length / 2) * 18, wordItemPos.y);
        const totalChars = hSelectedCells.length;
        for (let i = 0; i < totalChars; i++) {
            const cell = hSelectedCells[i];
            const cellNode = this.gridCells[cell.x][cell.y];
            let startPos = cellNode.getPosition();
            startPos = this.gridGroup.convertToWorldSpaceAR(startPos);
            let targetPos = cc.v2(wordItemPos.x + i * 20, wordItemPos.y);
            if (cellNode) {
                const index = i;  // 保存当前索引到独立变量
                EffectManager.instance.playCollectCharEffect(this.itemCharPrefab, this.cellSize, cellNode.getComponent(ItemChar).label.string, startPos, targetPos, () => {
                    if (index === totalChars - 1) {
                        this.updateWordItem(wordIndex, true);
                        if (passLevel) {
                            this.onLevelComplete();
                        }
                    }
                });
            }
        }

        // 等待0.5秒,再往下执行
        await new Promise(resolve => setTimeout(resolve, 140));

        if (!passLevel) {
            let reward = GameMgr.Instance.addWordFinishReward();
            if (reward > 0) {
                // 播放收集金币动画
                let startCell = hSelectedCells[0];
                let startPos = this.gridGroup.convertToWorldSpaceAR(
                    this.gridCells[startCell.x][startCell.y].getPosition()
                );

                let targetPos = UIManager.Instance.getTargetNodeWorldPosition(TargetNodeKeys.ICON_MONEY);
                if (targetPos) {
                    SoundManager.Instance.PlaySound(SOUND_NAME.CollectMoney);
                    EffectManager.instance.playCollectEffect(CollectEffectType.Money, 5, startPos, targetPos, () => {
                        EventCenter.dispatchEvent(EventName.RefreshMoneyNumber, reward);
                    });
                }
            }
        }

        // 播放连击动画
        let wordInfo = this.findWordInGrid(word);
        if (wordInfo) {
            this.comboRoot.onFound(word, wordInfo.direction);
        }
    }

    private onWordNotFound() {
        Log.Debug("onWordNotFound");
        if (this.selectedCells.length > 2) {
            SoundManager.Instance.PlaySound(SOUND_NAME.WordError);
        }
        this.showErrorEffect();
        this.comboRoot.reset();
    }

    private onWordFounded() {
        this.showFoundedEffect();
        this.comboRoot.reset();
    }

    private highlightFoundWord(word: string, color: cc.Color) {
        let wordInfo = this.findWordInGrid(word);
        if (!wordInfo) {
            // 如果word未找到，将word倒序
            const reversedWord = word.split('').reverse().join('');
            wordInfo = this.findWordInGrid(reversedWord);
            if (!wordInfo) {
                Log.Error(`未找到单词 ${word} 的位置信息`);
                return;
            }
        }

        this.markCellsAsFound(wordInfo);
        this.createFoundWordEffect(wordInfo, color);
    }

    private markCellsAsFound(wordInfo: WordInfo) {
        for (let i = 0; i < wordInfo.length; i++) {
            const row = wordInfo.startRow + wordInfo.direction.y * i;
            const col = wordInfo.startCol + wordInfo.direction.x * i;
            const cellNode = this.gridCells[row]?.[col];

            if (cellNode) {
                const itemChar = cellNode.getComponent(ItemChar);
                if (itemChar) {
                    itemChar.setFound(true);
                }
            }
        }
    }

    private createFoundWordEffect(wordInfo: WordInfo, color: cc.Color) {
        const startCell = this.gridCells[wordInfo.startRow][wordInfo.startCol];
        if (!startCell) return;

        const effect = ObjectPoolManager.instance.getNode(this.itemSelectEffectPrefab);
        this.selectEffectGroup.addChild(effect);
        const selectEffect = effect.getComponent(ItemSelectEffect) as ItemSelectEffect;

        const { startPos, distance } = this.calculateWordDistance(wordInfo);
        selectEffect.playFinishEffect(startPos, distance, wordInfo.direction, color);

        this.currentFoundEffects.push(selectEffect);
    }

    private showErrorEffect() {
        this.selectedCells.forEach(cell => {
            const cellNode = this.gridCells[cell.x]?.[cell.y];
            if (cellNode) {
                const itemChar = cellNode.getComponent(ItemChar);
                if (itemChar) {
                    itemChar.setError();
                    itemChar.reset();
                }
            }
        });

        this.showSelectItem.showErrorAnimation();
    }

    private showFoundedEffect() {
        this.selectedCells.forEach(cell => {
            const cellNode = this.gridCells[cell.x]?.[cell.y];
            if (cellNode) {
                const itemChar = cellNode.getComponent(ItemChar);
                if (itemChar) {
                    itemChar.setError();
                    itemChar.reset();
                }
            }
        });

        this.showSelectItem.showFoundedAnimation();
    }

    private updateWordItem(wordIndex: number, found: boolean) {
        const wordItem = this.wordItems[wordIndex];
        if (!wordItem) return;

        const itemWord = wordItem.getComponent(ItemWord);
        if (itemWord) {
            itemWord.setFound(found);
        }
    }

    // ========== 单词查找 ==========
    private findWordInGrid(word: string): WordInfo | null {
        if (!this.currentGameData || !word) return null;

        const { rows, cols } = this.currentGameData.gridSize;

        for (let row = 0; row < rows; row++) {
            for (let col = 0; col < cols; col++) {
                if (this.currentDirection) {
                    if (this.checkWordInDirection(word, row, col, this.currentDirection)) {
                        const cells = this.getCellsInDirection(word, row, col, this.currentDirection);
                        return {
                            startRow: row,
                            startCol: col,
                            direction: this.currentDirection,
                            length: word.length,
                            cells: cells
                        };
                    }
                } else {
                    for (const direction of this.SEARCH_DIRECTIONS) {
                        if (this.checkWordInDirection(word, row, col, direction)) {
                            const cells = this.getCellsInDirection(word, row, col, direction);
                            return {
                                startRow: row,
                                startCol: col,
                                direction: direction,
                                length: word.length,
                                cells: cells
                            };
                        }
                    }
                }
            }
        }

        return null;
    }

    private checkWordInDirection(word: string, startRow: number, startCol: number, direction: cc.Vec2): boolean {
        const { rows, cols } = this.currentGameData.gridSize;
        const grid = this.currentGameData.grid;

        const endRow = startRow + direction.y * (word.length - 1);
        const endCol = startCol + direction.x * (word.length - 1);

        if (endRow < 0 || endRow >= rows || endCol < 0 || endCol >= cols) {
            return false;
        }

        for (let i = 0; i < word.length; i++) {
            const currentRow = startRow + direction.y * i;
            const currentCol = startCol + direction.x * i;

            if (grid[currentRow][currentCol] !== word[i]) {
                return false;
            }
        }

        return true;
    }

    private getCellsInDirection(word: string, startRow: number, startCol: number, direction: cc.Vec2): cc.Vec2[] {
        const cells = [];
        for (let i = 0; i < word.length; i++) {
            const currentRow = startRow + direction.y * i;
            const currentCol = startCol + direction.x * i;
            cells.push(cc.v2(currentRow, currentCol));
        }
        return cells;
    }

    // ========== 效果管理 ==========
    /**
     * 播放提示动画效果，模拟玩家滑动选中
     * @param wordInfo 单词信息
     * @param color 颜色
     */
    private playHintAnimation(wordInfo: WordInfo, color: cc.Color) {
        if (!wordInfo || !wordInfo.cells || wordInfo.cells.length === 0) {
            Log.Error('wordInfo 数据无效');
            return;
        }

        Log.Debug('zq_playHintAnimation 开始播放提示动画');

        // 设置提示动画状态，防止触摸事件干扰
        this.isPlayingHintAnimation = true;

        // 1. 设置起始单元格（从 wordInfo.cells 的第一个位置）
        const startCellPos = wordInfo.cells[0]; // cc.Vec2(row, col)
        const startRow = startCellPos.x;
        const startCol = startCellPos.y;

        // 设置选择状态
        this.clearSelection();
        this.isSelecting = true;
        this.startCell = cc.v2(startRow, startCol);
        this.selectedCells = [];
        this.currentColor = color;

        // 创建选中效果
        this.createSelectEffect(startRow, startCol);
        this.showSelectItem.updateShow([this.startCell], this.currentColor);

        // 2. 获取结束单元格位置并计算 localPos
        const endCellPos = wordInfo.cells[wordInfo.cells.length - 1];
        const endRow = endCellPos.x;
        const endCol = endCellPos.y;

        // 获取起始和结束单元格的节点位置
        const startNodePos = this.gridCells[startRow][startCol].getPosition();
        const endNodePos = this.gridCells[endRow][endCol].getPosition();

        Log.Debug('zq_playHintAnimation 起始位置:', startNodePos, '结束位置:', endNodePos);

        // 3. 创建平滑的动画效果，分步模拟滑动
        const animationSteps = 30; // 动画分成20步
        const stepDuration = 10; // 每步10毫秒，总共200毫秒
        let currentStep = 0;

        const animateStep = () => {
            currentStep++;
            const progress = currentStep / animationSteps;

            // 计算当前步骤的位置（线性插值）
            const currentPos = startNodePos.lerp(endNodePos, progress);

            // Log.Debug(`zq_playHintAnimation 步骤 ${currentStep}/${animationSteps}, progress: ${progress}, currentPos:`, currentPos);

            try {
                // 4. 调用 updateSelectedCellsFromPosition 模拟滑动
                this.updateSelectedCellsFromPosition(currentPos);
            } catch (error) {
                Log.Error('zq_playHintAnimation updateSelectedCellsFromPosition 出错:', error);
                this.isPlayingHintAnimation = false;
                return;
            }

            if (currentStep < animationSteps) {
                // 继续下一步动画 - 使用 setTimeout 避免 scheduleOnce 的重复调度问题
                setTimeout(animateStep, stepDuration);
            } else {
                // 动画完成后，等待100毫秒再验证单词（总共0.5秒：0.4秒动画 + 0.1秒等待）
                Log.Debug('zq_playHintAnimation 动画完成，准备验证单词');
                setTimeout(() => {
                    // 5. 调用 validateSelectedWord 验证单词
                    this.validateSelectedWord();
                    this.clearSelection();
                    this.isSelecting = false;
                    this.isPlayingHintAnimation = false;
                    Log.Debug('zq_playHintAnimation 提示动画完全结束');
                }, 100);
            }
        };

        // 开始动画 - 使用 setTimeout
        setTimeout(animateStep, stepDuration);
    }

    private showTipEffect(wordInfo: WordInfo, color: cc.Color) {
        const startCell = this.gridCells[wordInfo.startRow][wordInfo.startCol];
        if (!startCell) return;

        const effect = ObjectPoolManager.instance.getNode(this.itemSelectEffectPrefab);
        this.selectEffectGroup.addChild(effect);
        this.currentTipEffect = effect.getComponent(ItemSelectEffect);

        const { startPos, distance } = this.calculateWordDistance(wordInfo);
        this.currentTipEffect.playBreathEffect(startPos, distance, wordInfo.direction, color);
    }

    private createSelectEffect(row: number, col: number) {
        const effect = ObjectPoolManager.instance.getNode(this.itemSelectEffectPrefab);
        this.selectEffectGroup.addChild(effect);
        this.currentSelectEffect = effect.getComponent(ItemSelectEffect);

        const startPos = this.gridCells[row][col].getPosition();
        this.currentSelectEffect.setPosition(startPos, this.startCell);
        this.currentSelectEffect.setColor(this.currentColor);
    }

    private calculateWordDistance(wordInfo: WordInfo): { startPos: cc.Vec2, distance: number } {
        const startCell = this.gridCells[wordInfo.startRow][wordInfo.startCol];
        const endRow = wordInfo.startRow + wordInfo.direction.y * (wordInfo.length - 1);
        const endCol = wordInfo.startCol + wordInfo.direction.x * (wordInfo.length - 1);
        const endCell = this.gridCells[endRow][endCol];

        const startPos = startCell.getPosition();
        const endPos = endCell.getPosition();
        const distance = cc.Vec2.distance(startPos, endPos);

        return { startPos, distance };
    }

    // ========== 网格旋转 ==========
    private playRotationAnimation() {
        const gridParent = this.gridGroup.parent;
        if (!gridParent) {
            Log.Error('无法找到GridGroup的父节点');
            return;
        }
        SoundManager.Instance.PlaySound(SOUND_NAME.BulbRotate);
        this.isRotating = true;
        cc.tween(gridParent)
            .to(0.07, { scale: 1.1 })
            .to(0.2, { scale: 0.7 })
            .by(0.5, { angle: -180 })
            .to(0.2, { scale: 1 })
            .call(() => {
                Log.Debug('网格旋转完成');
                this.gridCells.forEach(row => {
                    row.forEach(cellNode => {
                        if (cellNode) {
                            cellNode.angle = -gridParent.angle;
                        }
                    });
                });
                this.isRotating = false;
            })
            .start();
    }

    // ========== 辅助方法 ==========
    private getCellSize(): number {
        if (!this.currentGameData) return 60;

        if (this.cellSize > 0) {
            return this.cellSize;
        }

        const { rows, cols } = this.currentGameData.gridSize;
        this.cellSize = Math.min(
            (this.GRID_WIDTH - (cols - 1) * this.SPACING) / cols,
            (this.GRID_HEIGHT - (rows - 1) * this.SPACING) / rows
        );
        return this.cellSize;
    }

    private getGridStartPosition(cellSize: number): { startX: number, startY: number } {
        const { rows, cols } = this.currentGameData.gridSize;
        const totalWidth = cols * cellSize + (cols - 1) * this.SPACING;
        const totalHeight = rows * cellSize + (rows - 1) * this.SPACING;

        return {
            startX: -totalWidth / 2 + cellSize / 2,
            startY: -totalHeight / 2 + cellSize / 2
        };
    }

    private getCellPositionFromWorldPos(localPos: cc.Vec2): { row: number, col: number } | null {
        if (!this.currentGameData) return null;

        const cellSize = this.getCellSize();
        const { startX, startY } = this.getGridStartPosition(cellSize);
        const { rows, cols } = this.currentGameData.gridSize;

        const col = Math.floor((localPos.x - startX + cellSize / 2) / (cellSize + this.SPACING));
        const row = Math.floor((localPos.y - startY + cellSize / 2) / (cellSize + this.SPACING));

        if (this.isValidCell(row, col)) {
            return { row, col };
        }

        return null;
    }

    private isValidCell(row: number, col: number): boolean {
        const { rows, cols } = this.currentGameData.gridSize;
        return row >= 0 && row < rows && col >= 0 && col < cols;
    }

    // ========== 清理回收 ==========
    private cleanupCurrentLevel() {
        this.removeGridTouchEvents();
        this.recycleWordItems();
        this.recycleGridCells();
        this.recycleSelectEffect();
        this.recycleTipEffect();
        this.recycleFoundEffects();

        this.isSelecting = false;
        this.selectedCells = [];
        this.startCell = null;
        this.currentColor = null;
        this.cellSize = 0;
    }

    private recycleWordItems() {
        this.wordItems.forEach(wordItem => {
            if (wordItem && wordItem.parent) {
                const itemWord = wordItem.getComponent(ItemWord);
                if (itemWord) {
                    itemWord.reset();
                }
                wordItem.removeFromParent();
                ObjectPoolManager.instance.putNode(wordItem);
            }
        });
        this.wordItems = [];
    }

    private recycleGridCells() {
        Log.Debug("recycleGridCells");
        this.gridCells.forEach(row => {
            row.forEach(cellNode => {
                if (cellNode && cellNode.parent) {
                    const itemChar = cellNode.getComponent(ItemChar);
                    if (itemChar) {
                        itemChar.reset();
                    }
                    cellNode.removeFromParent();
                    ObjectPoolManager.instance.putNode(cellNode);
                }
            });
        });
        this.gridCells = [];
        this.selectedCells = [];
    }

    private recycleSelectEffect() {
        if (this.currentSelectEffect) {
            this.currentSelectEffect.recycle();
        }
        this.currentSelectEffect = null;
    }

    private recycleTipEffect() {
        if (this.currentTipEffect) {
            this.currentTipEffect.recycle();
        }
        this.currentTipEffect = null;
    }

    private recycleFoundEffects() {
        this.currentFoundEffects.forEach(effect => {
            if (effect && effect.node) {
                ObjectPoolManager.instance.putNode(effect.node);
            }
        });
        this.currentFoundEffects = [];
    }

    private onGuideSwipeComplete() {
        Log.Debug('GameUI onGuideSwipeComplete - 滑动引导完成');
        // 可以在这里添加滑动引导完成后的逻辑
        // 例如：播放音效、显示提示等
    }

    /**
     * 处理来自引导系统的触摸事件
     * @param event 触摸事件
     * @param eventType 事件类型
     */
    public handleGuideTouchEvent(event: cc.Event.EventTouch, eventType: string) {
        switch (eventType) {
            case cc.Node.EventType.TOUCH_START:
                this.onGridTouchStart(event);
                break;
            case cc.Node.EventType.TOUCH_MOVE:
                this.onGridTouchMove(event);
                break;
            case cc.Node.EventType.TOUCH_END:
                this.onGridTouchEnd(event);
                break;
            case cc.Node.EventType.TOUCH_CANCEL:
                this.onGridTouchCancel(event);
                break;
        }
    }

    private onDisposeEvent() {
        EventCenter.off(EventName.UpdateTipNumber, this.onUpdateTipNumber, this);
        EventCenter.off(EventName.UseHitEvent, this.onUseHitEvent, this);
        EventCenter.off(EventName.GuideSwipeComplete, this.onGuideSwipeComplete, this);
        EventCenter.off(EventName.PopRewardClose, this.onPopRewardClose, this);
        UIManager.Instance.unregisterTargetNode(TargetNodeKeys.ICON_HIT);
    }
}

