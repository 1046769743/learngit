/**
 * 对象池管理类
 */
import { Log } from '../FrameWork/Log';
const { ccclass, property } = cc._decorator;

@ccclass
export class ObjectPoolManager {
    public static _instance: ObjectPoolManager = null;
    public static get instance(): ObjectPoolManager {
        if (!this._instance) {
            this._instance = new ObjectPoolManager();
        }
        return this._instance;
    }
    private dictPool: any = {}

    constructor() {
    }

    /**
     * 根据预设从对象池中获取对应节点
     */
    public getNode(prefab: cc.Node | cc.Prefab, name: string = null) {
        if (!name) {
            name = prefab.name;
        }
        let node = null;
        if (this.dictPool.hasOwnProperty(name)) { //指示对象自身属性中是否具有指定的属性（也就是，是否有指定的键）
            //已有对应的对象池
            let pool = this.dictPool[name];
            if (pool.size() > 0) {
                node = pool.get();
            } else {
                node = cc.instantiate(prefab);
            }
        } else {
            //没有对应对象池，创建他！
            let pool = new cc.NodePool();
            this.dictPool[name] = pool;

            node = cc.instantiate(prefab);
        }

        // 确保节点的 name 与池的 key 一致，防止跨池污染
        node.name = name;
        return node;
    }

    public getNodeByName(name: string) {
        let node = null;
        if (this.dictPool.hasOwnProperty(name)) { //指示对象自身属性中是否具有指定的属性（也就是，是否有指定的键）
            //已有对应的对象池
            let pool = this.dictPool[name];
            if (pool.size() > 0) {
                node = pool.get();
            }
        }

        return node;
    }

    /**
     * 将对应节点放回对象池中
     */
    public putNode(node: cc.Node) {
        let name = node.name;
        Log.Debug("ObjectPoolManager putNode name = " + name);
        let pool = null;
        if (this.dictPool.hasOwnProperty(name)) {
            //已有对应的对象池
            pool = this.dictPool[name];
        } else {
            //没有对应对象池，创建他！
            pool = new cc.NodePool();
            this.dictPool[name] = pool;
        }

        pool.put(node);
    }

    /**
     * 根据名称，清除对应对象池
     * @param {string} name 
     */
    public clearPool(name: string) {
        if (this.dictPool.hasOwnProperty(name)) {
            let pool = this.dictPool[name];
            pool.clear();
        }
    }
}
