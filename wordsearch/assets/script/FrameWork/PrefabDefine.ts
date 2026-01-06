/**
 * 资源名字到路径的映射
 */
export class PrefabDefine {
    static GameUI: string = "GameUI";
    static HomeUI: string = "HomeUI";
    static GuideUI: string = "GuideUI";
    static PopDebug: string = "PopDebug";
    // static GuideUI: string = "GuideUI";
    static PopGameWin: string = "PopGameWin";
    static PopSetting: string = "PopSetting";
    static PopWithdraw: string = "PopWithdraw";
    static PopTips: string = "PopTips";
    static PopWheel: string = "PopWheel";
    static PopReward: string = "PopReward";
    static PopRewardClaim: string = "PopRewardClaim";
    static PopTask: string = "PopTask"
    static PopAdTest: string = "PopAdTest";
    static PopJackpoy: string = "PopJackpoy";
    static PopFlyBox: string = "PopFlyBox";
    static PopLuckWheel: string = "PopLuckWheel";
    static PopPig: string = "PopPig";
    static PopPigAnim: string = "PopPigAnim";
    static PopDailyLogin: string = "PopDailyLogin";
    static PopCashOut: string = "PopCashOut";


    private static _resList: Map<string, string> = new Map<string, string>([
        [PrefabDefine.GameUI, "Prefab/UI/GameUI"],
        [PrefabDefine.HomeUI, "Prefab/UI/HomeUI"],
        [PrefabDefine.GuideUI, "Prefab/UI/GuideUI"],
        [PrefabDefine.PopDebug, "Prefab/Pop/PopDebug"],
        // [PrefabDefine.GuideUI, "Prefab/GuideUI"],
        [PrefabDefine.PopGameWin, "Prefab/Pop/PopGameWin"],
        [PrefabDefine.PopSetting, "Prefab/Pop/PopSetting"],
        [PrefabDefine.PopWithdraw, "Prefab/Pop/PopWithdraw"],
        [PrefabDefine.PopTips, "Prefab/Pop/PopTips"],
        [PrefabDefine.PopWheel, "Prefab/Pop/PopWheel"],
        [PrefabDefine.PopReward, "Prefab/Pop/PopReward"],
        [PrefabDefine.PopRewardClaim, "Prefab/Pop/PopRewardClaim"],
        [PrefabDefine.PopTask, "Prefab/Pop/PopTask"],
        [PrefabDefine.PopAdTest, "Prefab/Pop/PopAdTest"],
        [PrefabDefine.PopJackpoy, "Prefab/Pop/PopJackpoy"],
        [PrefabDefine.PopFlyBox, "Prefab/Pop/PopFlyBox"],
        [PrefabDefine.PopLuckWheel, "Prefab/Pop/PopLuckWheel"],
        [PrefabDefine.PopPig, "Prefab/Pop/PopPig"],
        [PrefabDefine.PopPigAnim, "Prefab/Pop/PopPigAnim"],
        [PrefabDefine.PopDailyLogin, "Prefab/Pop/PopDailyLogin"],
        [PrefabDefine.PopCashOut, "Prefab/Pop/PopCashOut"],

    ]);

    static getPath(name: string): string {
        return this._resList.get(name);
    }
}