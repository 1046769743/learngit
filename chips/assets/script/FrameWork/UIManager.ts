import { EventName } from '../Common/EventName';
import { ObjectPoolManager } from '../Common/ObjectPoolManager';
import { EventCenter } from './EventCenter';
import Language from '../Module/Language/Language';
import ItemTips from '../View/Item/ItemTips';
import BasePop from '../View/Pop/BasePop';
import { Log } from './Log';
import { PrefabDefine } from './PrefabDefine';
const { ccclass, property } = cc._decorator;

export enum UILayer {
    Game,
    UI,
    PopUp,
    Top,
    Effect,
    Guide,
    Loading,
    Tip
}

@ccclass
export class UIManager extends cc.Component {
    private static _instance: UIManager;

    static get Instance() {
        return UIManager._instance;
    }

    isInitOk: boolean = false; // 是否初始化完成的标记

    /*-------------------- Canvas下各个层级的节点 --------------------*/

    @property(cc.Node)
    GameLayer: cc.Node = null; // 游戏层

    @property(cc.Node)
    UILayer: cc.Node = null; // UI层

    @property(cc.Node)
    PopUpLayer: cc.Node = null; // 弹窗层

    @property(cc.Node)
    TopLayer: cc.Node = null; // 提示层

    @property(cc.Node)
    EffectLayer: cc.Node = null; // 特效层

    @property(cc.Node)
    GuideLayer: cc.Node = null; // 新手引导层

    @property(cc.Node)
    LoadingLayer: cc.Node = null; // 加载层

    @property(cc.Node)
    TipLayer: cc.Node = null; // 提示层

    @property(cc.Camera)
    UICamera: cc.Camera = null; //UI相机

    @property(cc.Prefab)
    prefabItemTips: cc.Prefab = null;

    /*-------------------- Canvas下各个层级的节点 --------------------*/

    private _currentUIName: string = ""; // 当前显示的UI名字
    private _currentUI: cc.Node = null; // 当前显示的UI

    private _popupStack: cc.Node[] = []; // 弹窗栈

    private _loadingStack: string[] = []; // 加载栈

    private _uiStack: any = {}; // 其他层的ui缓存 UIpath =》 node

    // 目标节点缓存（用于收集动画等）
    private _targetNodes: Map<string, cc.Node> = new Map();

    /**
     * 初始化
     */
    start() {
        UIManager._instance = this;
        this.isInitOk = true;
        Log.Debug("UIManager init ok!");

    }

    /**
     * 注册目标节点
     * @param key 节点标识
     * @param node 节点引用
     */
    public registerTargetNode(key: string, node: cc.Node) {
        this._targetNodes.set(key, node);
        Log.Debug(`注册目标节点: ${key}`);
    }

    /**
     * 取消注册目标节点
     * @param key 节点标识
     */
    public unregisterTargetNode(key: string) {
        this._targetNodes.delete(key);
        Log.Debug(`取消注册目标节点: ${key}`);
    }

    /**
     * 获取目标节点的世界坐标
     * @param key 节点标识
     * @returns 世界坐标，如果节点不存在返回null
     */
    public getTargetNodeWorldPosition(key: string): cc.Vec2 | null {
        const node = this._targetNodes.get(key);
        if (!node || !node.isValid) {
            Log.Warning(`目标节点不存在或已销毁: ${key}`);
            return null;
        }
        return node.parent.convertToWorldSpaceAR(node.getPosition());
    }

    /** 获取目标节点 */
    public getTargetNode(key: string): cc.Node | null {
        return this._targetNodes.get(key);
    }
    /**
     * 显示UI，切换主UI显示
     * @param name 
     * @param args 
     */
    showHUD(name: string, callback: Function = null): void {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            if (callback) callback(null);
            return;
        }

        if (this._currentUI != null && this._currentUIName == name) {
            if (callback) callback(this._currentUI);
            return;
        }

        // 加载预制体
        this._getPrefab(name, (parfab: any) => {
            if (!parfab) {
                if (callback) callback(null);
                return;
            }

            var oldNode: cc.Node = this._currentUI;

            // 从获取到的预制体中实例化节点
            this._currentUI = cc.instantiate(parfab);
            this._currentUIName = name;

            this._currentUI.active = true;

            this.UILayer.addChild(this._currentUI);

            // 销毁旧的
            if (oldNode) {
                oldNode.destroy();
            }

            if (callback) callback(this._currentUI);
        });
    }

    /**
     * 隐藏UI，切换主UI显示
     * @param name 
     */
    hideHUD(name: string): void {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        if (this._currentUI == null || this._currentUIName != name) {
            return;
        }

        this._currentUI.active = false;
    }

    /**
     * 打开界面
     * @param uiName
     * @param args
     */
    open(name: string, callback: Function = null) {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            if (callback) callback(null);
            return;
        }

        // 如果界面已打开，则直接返回
        let node = this.find(name);
        if (node) {
            if (callback) callback(node);
            return;
        }
        if (this._loadingStack.indexOf(name) != -1) {
            Log.Debug("UIManager 正在加载界面: " + name + " 加载栈: " + this._loadingStack.join(","));
            return;
        }

        this._loadingStack.push(name);
        // 加载预制体
        this._getPrefab(name, (parfab: any) => {
            this._loadingStack.splice(this._loadingStack.indexOf(name), 1);
            if (!parfab) {
                if (callback) callback(null);
                return;
            }

            // 从获取到的预制体中实例化节点
            node = cc.instantiate(parfab);

            // 将节点添加到弹窗层
            this.PopUpLayer.addChild(node);

            // 将节点添加到弹窗栈
            this._popupStack.push(node);

            let basePop = node.getComponent(BasePop);
            if (basePop) {
                basePop.showEnterAnim();
            }

            if (callback) callback(node);
        });
    }

    /**
     * 关闭界面
     * @param uiName
     */
    close(name: string) {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        let node = this.find(name);
        if (!node) {
            return;
        }

        // 从弹窗栈中移除
        let index = this._popupStack.indexOf(node);
        if (index != -1) {
            this._popupStack.splice(index, 1);
        }

        // let path = PrefabDefine.getPath(name);

        // resources.release(path);
        let basePop = node.getComponent(BasePop) as BasePop;
        if (basePop) {
            basePop.hideCloseAnim(() => {
                // 派发弹窗关闭事件
                EventCenter.dispatchEvent(EventName.PopupClose, name);
                // 从父节点移除
                node.parent = null;
                node.destroy();
            });
        } else {
            // 派发弹窗关闭事件
            EventCenter.dispatchEvent(EventName.PopupClose, name);
            // 从父节点移除
            node.parent = null;
            node.destroy();
        }
    }

    /**
     * 关闭所有界面
     */
    closeAll() {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        // 遍历弹窗栈，释放所有节点
        while (this._popupStack.length > 0) {
            let node = this._popupStack.pop();
            node.destroy();
        }
    }

    /**
     * 查找界面
     * @param uiName
     */
    find(name: string): any {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        // 遍历_popupStack，查找是否有该界面
        for (let i = 0; i < this._popupStack.length; i++) {
            let node = this._popupStack[i];
            if (node.name == name) {
                return node;
            }
        }

        return null;
    }

    /**
     * 获取最顶层界面
     */
    get top(): any {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        if (this._popupStack.length > 0) {
            return this._popupStack[this._popupStack.length - 1];
        }

        return null;
    }

    /**
     * 根据名字获取预制体
     * @param name 
     */
    private _getPrefab(name: string, callback: Function) {
        const path: string = PrefabDefine.getPath(name);

        if (!path) {
            Log.Error(`PrefabDefine not find name: ${name}`);
            callback(null);
            return;
        }

        // 通过resources加载预制体
        cc.resources.load(path, (err, prefab) => {
            if (err) {
                Log.Error(`load prefab error: ${err}`);
                callback(null);
                return;
            }

            callback(prefab);
        });
    }

    /**
     * 将制定UI显示在指定层级
     * @param name 
     * @param args 
     */
    showUIOnLayer(name: string, layer: UILayer, callback: Function = null): void {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            if (callback) callback(null);
            return;
        }

        if (layer == UILayer.Game || layer == UILayer.UI || layer == UILayer.PopUp) {
            Log.Error("[UIManager] don't use showUIOnLayer for Game, UI, PopUp layer!");
            if (callback) callback(null);
            return;
        }

        var self = this;
        // 加载预制体
        this._getPrefab(name, (parfab: any) => {
            if (!parfab) {
                if (callback) callback(null);
                return;
            }

            var obj = cc.instantiate(parfab);

            switch (layer) {
                case UILayer.Top:
                    this.TopLayer.addChild(obj);
                    break;

                case UILayer.Effect:
                    this.EffectLayer.addChild(obj);
                    break;

                case UILayer.Guide:
                    this.GuideLayer.addChild(obj);
                    break;

                case UILayer.Loading:
                    this.LoadingLayer.addChild(obj);
                    break;

                case UILayer.Tip:
                    this.TipLayer.addChild(obj);
                    break;
            }

            self._uiStack[name] = obj;

            if (callback) callback(obj);
        });
    }

    /**
     * 将制定UI从指定层级移除
     */
    hideUIFromLayer(name: string): void {
        if (!this.isInitOk) {
            Log.Error("UIManager not init ok!");
            return;
        }

        var obj = this._uiStack[name];
        if (obj) {
            obj.parent = null;
            obj.destroy();
            delete this._uiStack[name];
        }
    }

    public showToast(key: string, content: string = "") {
        let node = ObjectPoolManager.instance.getNode(this.prefabItemTips, "ItemTips");
        if (node) {
            if (content == "") {
                content = Language.instance.getDes(key);
            }
            this.TipLayer.addChild(node);
            node.getComponent(ItemTips).initContent(content);
        }
    }
}

