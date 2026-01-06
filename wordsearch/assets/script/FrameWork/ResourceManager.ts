import { Log } from "./Log";

const { ccclass, property } = cc._decorator;

export class LoadProgress {
    public url: string;
    public completedCount: number;
    public totalCount: number;
    public item: any;
    public cb?: Function;
}

/** 一些cocos api 的封装, promise函数统一加上sync后缀 */
export default class ResourceManager {

    /** 加载进度 */
    public static loadProgress = new LoadProgress();

    public static loadRes<T>(url: string, type: typeof cc.Asset, callback: Function) {
        cc.resources.load(url, type, (err, asset) => {
            if (err) {
                Log.Error(`load resource error: ${err}, url: ${url}`);
                callback(null);
                return;
            }

            callback(asset);
        });
    }

    /** 加载资源 */
    public static loadResSync<T>(url: string, type: typeof cc.Asset, onProgress?: (completedCount: number, totalCount: number, item: any) => void): Promise<T> {
        // cc.log("loadResSync ==> url: " + url);
        return new Promise((resolve, reject) => {
            if (!onProgress) onProgress = this._onProgress;
            cc.resources.load(url, type, onProgress, (err, asset: any) => {
                if (err) {
                    cc.error(`${url} [资源加载] 错误 ${err}`);
                    resolve(null);
                } else {
                    resolve(asset);
                }
            });
        });
    }
    /** 
     * 加载进度
     * cb方法 其实目的是可以将loader方法的progress
     */
    private static _onProgress(completedCount: number, totalCount: number, item: any) {
        ResourceManager.loadProgress.completedCount = completedCount;
        ResourceManager.loadProgress.totalCount = totalCount;
        ResourceManager.loadProgress.item = item;
        ResourceManager.loadProgress.cb && ResourceManager.loadProgress.cb(completedCount, totalCount, item);
    }

    /** 加载bundle */
    public static loadBundleSync(url: string, options: any): Promise<cc.AssetManager.Bundle> {
        return new Promise((resolve, reject) => {
            cc.assetManager.loadBundle(url, options, (err: Error, bundle: cc.AssetManager.Bundle) => {
                if (!err) {
                    cc.error(`加载bundle失败, url: ${url}, err:${err}`);
                    resolve(null);
                } else {
                    resolve(bundle);
                }
            });
        });
    }

    /** 路径是相对分包文件夹路径的相对路径 */
    public static loadAssetFromBundleSync(bundleName: string, url: string) {
        let bundle = cc.assetManager.getBundle(bundleName);
        if (!bundle) {
            cc.error(`加载bundle中的资源失败, 未找到bundle, bundleUrl:${bundleName}`);
            return null;
        }
        return new Promise((resolve, reject) => {
            bundle.load(url, (err, asset: cc.Asset | cc.Asset[]) => {
                if (err) {
                    cc.error(`加载bundle中的资源失败, 未找到asset, url:${url}, err:${err}`);
                    resolve(null);
                } else {
                    resolve(asset);
                }
            });
        });
    }

    /** 通过路径加载资源, 如果这个资源在bundle内, 会先加载bundle, 在解开bundle获得对应的资源 */
    public static loadAssetSync(url: string, type: typeof cc.Asset) {
        return new Promise((resolve, reject) => {
            cc.resources.load(url, type, (err, assets: cc.Asset | cc.Asset[]) => {
                if (err) {
                    cc.error(`加载asset失败, url:${url}, err: ${err}`);
                    resolve(null);
                } else {

                    this.addRef(assets);
                    resolve(assets);
                }
            });
        });
    }
    /** 释放资源 */
    public static releaseAsset(assets: cc.Asset | cc.Asset[]) {
        this.decRes(assets);
    }
    /** 增加引用计数 */
    private static addRef(assets: cc.Asset | cc.Asset[]) {
        if (assets instanceof Array) {
            for (const a of assets) {
                a.addRef();
            }
        } else {
            assets.addRef();
        }
    }
    /** 减少引用计数, 当引用计数减少到0时,会自动销毁 */
    private static decRes(assets: cc.Asset | cc.Asset[]) {
        if (assets instanceof Array) {
            for (const a of assets) {
                a.decRef();
            }
        } else {
            assets.decRef();
        }
    }
}


