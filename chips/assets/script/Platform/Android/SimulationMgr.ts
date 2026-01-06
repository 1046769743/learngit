import { Log } from "../../FrameWork/Log";
import { ReceiveEventManager } from "./ReceiveEventManager";

/**
 * 模拟和Android端的交互
 */
export class SimulationMgr {

    private static level: number = 5;
    private static is_show_new_user_guide: boolean = false;

    static onGameInitFinished() {
        Log.Debug("[SimulationMgr] onGameInitFinished");

        var guideStep = Number.parseInt(localStorage.getItem("guide_step"));

        if (isNaN(guideStep)) guideStep = 0;

        var data = {};
        data["user_name"] = "aaa";
        data["head_image_url"] = "https:\/\/thirdwx.qlogo.cn\/mmopen\/vi_32\/xxx\/132";
        data["user_level"] = this.level;
        data["red_packet_value"] = 12.0946;
        data["game_diamond_value"] = 100;
        data["float_box_interval"] = 150;
        data["red_packet_value"] = 1;
        data["game_guide_steps"] = guideStep;

        data["is_new_user_welfare_received"] = false;
        data["show_playlet_enter"] = true;
        data["auto_merge_chips_switch"] = true;

        // 筹码进度奖励配置
        var chips_progress_reward_config = {};
        chips_progress_reward_config["30"] = {};
        chips_progress_reward_config["30"]["reward_type"] = 3;
        chips_progress_reward_config["30"]["reward_value"] = 0;
        chips_progress_reward_config["30"]["is_play_move"] = false;

        chips_progress_reward_config["40"] = {};
        chips_progress_reward_config["40"]["reward_type"] = 1;
        chips_progress_reward_config["40"]["reward_value"] = 0.6;
        chips_progress_reward_config["40"]["is_play_move"] = false;

        chips_progress_reward_config["50"] = {};
        chips_progress_reward_config["50"]["reward_type"] = 1;
        chips_progress_reward_config["50"]["reward_value"] = 0;
        chips_progress_reward_config["50"]["is_play_move"] = false;

        chips_progress_reward_config["60"] = {};
        chips_progress_reward_config["60"]["reward_type"] = 1;
        chips_progress_reward_config["60"]["reward_value"] = 2;
        chips_progress_reward_config["60"]["is_play_move"] = false;

        chips_progress_reward_config["70"] = {};
        chips_progress_reward_config["70"]["reward_type"] = 2;
        chips_progress_reward_config["70"]["reward_value"] = 7;
        chips_progress_reward_config["70"]["is_play_move"] = false;

        chips_progress_reward_config["80"] = {};
        chips_progress_reward_config["80"]["reward_type"] = 1;
        chips_progress_reward_config["80"]["reward_value"] = 0.8;
        chips_progress_reward_config["80"]["is_play_move"] = false;

        chips_progress_reward_config["90"] = {};
        chips_progress_reward_config["90"]["reward_type"] = 2;
        chips_progress_reward_config["90"]["reward_value"] = 7;
        chips_progress_reward_config["90"]["is_play_move"] = false;

        chips_progress_reward_config["100"] = {};
        chips_progress_reward_config["100"]["reward_type"] = 1;
        chips_progress_reward_config["100"]["reward_value"] = 1.2;
        chips_progress_reward_config["100"]["is_play_move"] = false;


        chips_progress_reward_config["110"] = {};
        chips_progress_reward_config["110"]["reward_type"] = 2;
        chips_progress_reward_config["110"]["reward_value"] = 17;
        chips_progress_reward_config["110"]["is_play_move"] = false;


        chips_progress_reward_config["120"] = {};
        chips_progress_reward_config["120"]["reward_type"] = 1;
        chips_progress_reward_config["120"]["reward_value"] = 22.2;
        chips_progress_reward_config["120"]["is_play_move"] = true;

        chips_progress_reward_config["130"] = {};
        chips_progress_reward_config["130"]["reward_type"] = 1;
        chips_progress_reward_config["130"]["reward_value"] = 66.6;
        chips_progress_reward_config["130"]["is_play_move"] = false;

        chips_progress_reward_config["140"] = {};
        chips_progress_reward_config["140"]["reward_type"] = 2;
        chips_progress_reward_config["140"]["reward_value"] = 718;
        chips_progress_reward_config["140"]["is_play_move"] = false;


        chips_progress_reward_config["150"] = {};
        chips_progress_reward_config["150"]["reward_type"] = 3;
        //chips_progress_reward_config["150"]["reward_value"] = 718;
        chips_progress_reward_config["150"]["is_play_move"] = false;

        // 游戏配置
        var game_config_data = {};
        game_config_data["chips_reward_config"] = {
            "10": 0.001,
            "20": 0.001,
            "30": 0.003,
            "40": 0.4,
            "50": 0.5,
            "60": 0.6,
            "70": 0.7,
            "80": 0.8,
            "90": 0.9,
            "100": 1,
            "110": 1.1,
            "120": 1.2,
            "130": 1.2,
            "140": 1.2,
            "150": 1.2
        };
        game_config_data["chips_progress_reward_config"] = chips_progress_reward_config;
        game_config_data["shuffe_num_110"] = 3;
        game_config_data["game_guide_interval"] = 5;
        game_config_data["game_guide_count"] = 30;
        game_config_data["shuffle_empty_num"] = 6;
        game_config_data["game_progress_switch"] = true;
        game_config_data["game_progress_value_list"] = [30, 50, 80, 110, 130];
        game_config_data["deal_config"] = SimulationMgr.DealConfig();
        game_config_data["deal_color_config"] = SimulationMgr.DealColorConfig();
        game_config_data["guide_config"] = SimulationMgr.GuideConfig();
        game_config_data["unlock_slot_config"] = SimulationMgr.UnlockSlotConfig();

        //chip5新增：
        game_config_data["shuffle_start_limit_chips_level"] = 50;
        game_config_data["shuffle_limit_count"] = 3;
        game_config_data["remove_prop_start_limit_chips_level"] = 40;
        game_config_data["remove_prop_limit_count"] = 4;
        game_config_data["prop_pre_withdrawal_usage_count"] = 2;
        game_config_data["prop_post_withdrawal_usage_count"] = 8;
        game_config_data["remove_small_chip_config"] = SimulationMgr.RemoveSmallChipConfig();
        game_config_data["prop_icon_switch"] = false;

        data["game_config_json"] = game_config_data;

        localStorage.clear();
        var game_data_str = localStorage.getItem("game_data");

        if (game_data_str == null) game_data_str = "{}";

        // 游戏存档
        data["game_data"] = JSON.parse(game_data_str);

        ReceiveEventManager.OnGetGameStatusSuccessEvent(data);
    }

    static GuideConfig() {
        var data = {};

        var step1 = {};
        step1["id"] = "guide_0_1";
        step1["type"] = 0;
        step1["step"] = 1;
        step1["is_save"] = false;
        step1["tips"] = "点击选择。";
        step1["sound"] = "guide1";
        data[step1["id"]] = step1;

        var step2 = {};
        step2["id"] = "guide_0_2";
        step2["type"] = 0;
        step2["step"] = 2;
        step2["is_save"] = true;
        step2["tips"] = "同类型放一起哦。";
        step2["sound"] = "guide2";
        data[step2["id"]] = step2;

        var step3 = {};
        step3["id"] = "guide_0_3";
        step3["type"] = 0;
        step3["step"] = 3;
        step3["is_save"] = true;
        step3["tips"] = "10个相同的牌，可合\n并为下一等级！";
        step3["sound"] = "guide3";
        data[step3["id"]] = step3;

        var step4 = {};
        step4["id"] = "guide_0_4";
        step4["type"] = 0;
        step4["step"] = 4;
        step4["is_save"] = true;
        step4["tips"] = "每次合成都可获得红包奖励，\n合成目标筹码即可全额提现。";
        step4["sound"] = "guide4";
        data[step4["id"]] = step4;

        var step5 = {};
        step5["id"] = "guide_0_5";
        step5["type"] = 0;
        step5["step"] = 5;
        step5["is_save"] = true;
        step5["tips"] = "获取更多的牌。";
        step5["sound"] = "guide5";
        data[step5["id"]] = step5;

        var step6 = {};
        step6["id"] = "guide_0_6";
        step6["type"] = 0;
        step6["step"] = 6;
        step6["is_save"] = false;
        step6["tips"] = "继续合成~";
        step6["sound"] = "guide6";
        data[step6["id"]] = step6;

        var step7 = {};
        step7["id"] = "guide_0_7";
        step7["type"] = 0;
        step7["step"] = 7;
        step7["is_save"] = true;
        step7["tips"] = "";
        step7["sound"] = "";
        data[step7["id"]] = step7;

        var step8 = {};
        step8["id"] = "guide_0_8";
        step8["type"] = 0;
        step8["step"] = 8;
        step8["is_save"] = false;
        step8["tips"] = "";
        step8["sound"] = "";
        data[step8["id"]] = step8;

        var step9 = {};
        step9["id"] = "guide_0_9";
        step9["type"] = 0;
        step9["step"] = 9;
        step9["is_save"] = true;
        step9["tips"] = "";
        step9["sound"] = "";
        data[step9["id"]] = step9;

        var step10 = {};
        step10["id"] = "guide_0_10";
        step10["type"] = 0;
        step10["step"] = 10;
        step10["is_save"] = true;
        step10["tips"] = "";
        step10["sound"] = "";
        data[step10["id"]] = step10;

        var step15 = {};
        step15["id"] = "guide_0_15";
        step15["type"] = 0;
        step15["step"] = 15;
        step15["is_save"] = true;
        step15["tips"] = "";
        step15["sound"] = "";
        data[step15["id"]] = step15;

        return data;
    }


    static DealConfig() {
        var chips_num = {};
        chips_num[0.5] = 0.6;
        chips_num[0.3] = 1;
        chips_num[0.6] = 1;
        var no_deal_card_trenth = "big";
        var strategy = {};
        strategy["match"] = 0.4;
        strategy["no_match_color_1"] = 0.8;
        strategy["no_match_color_2"] = 1;
        strategy["no_match_color_3"] = 1;

        var item = {};
        item["strategy"] = strategy;
        item["chips_num"] = chips_num;
        item["no_deal_card_trenth"] = no_deal_card_trenth;


        var config = {};
        config[10] = {}
        config[10]["0-10"] = item;
        // config[10]["2-4"] = item;
        // config[10]["4-10.1"] = item;

        config[20] = {}
        config[20]["0-10"] = item;
        // config[20]["2-4"] = item;
        // config[20]["4-10.1"] = item;

        config[30] = {}
        config[30]["0-10"] = item;
        // config[30]["2-4"] = item;
        // config[30]["4-10.1"] = item;

        config[40] = {}
        config[40]["0-10"] = item;
        // config[40]["2-4"] = item;
        // config[40]["4-10.1"] = item;

        config[50] = {}
        config[50]["0-2"] = item;
        config[50]["2-4"] = item;
        config[50]["4-10"] = item;

        config[60] = {}
        config[60]["0-2"] = item;
        config[60]["2-4"] = item;
        config[60]["4-10"] = item;

        config[70] = {}
        config[70]["0-2"] = item;
        config[70]["2-4"] = item;
        config[70]["4-10"] = item;

        config[80] = {}
        config[80]["0-2"] = item;
        config[80]["2-4"] = item;
        config[80]["4-10"] = item;

        config[90] = {}
        config[90]["0-2"] = item;
        config[90]["2-4"] = item;
        config[90]["4-10"] = item;

        config[100] = {}
        config[100]["0-2"] = item;
        config[100]["2-4"] = item;
        config[100]["4-10"] = item;

        config[110] = {}
        config[110]["0-2"] = item;
        config[110]["2-4"] = item;
        config[110]["4-10"] = item;

        config[120] = {}
        config[120]["0-2"] = item;
        config[120]["2-4"] = item;
        config[120]["4-10"] = item;

        config[130] = {}
        config[130]["0-2"] = item;
        config[130]["2-4"] = item;
        config[130]["4-10"] = item;

        config[140] = {}
        config[140]["0-2"] = item;
        config[140]["2-4"] = item;
        config[140]["4-10"] = item;

        config[150] = {}
        config[150]["0-2"] = item;
        config[150]["2-4"] = item;
        config[150]["4-10"] = item;

        // 160 - 300
        for (var i = 16; i <= 30; i++) {
            let num = i * 10;
            config[num] = {}
            config[num]["0-2"] = item;
            config[num]["2-4"] = item;
            config[num]["4-10"] = item;
        }


        return config;
    }

    static DealColorConfig() {
        var color_config = {};

        for (var i = 4; i <= 30; i++) {
            let num = i * 10;

            color_config[num] = "";
            for (let x = 1; x < i; x++) {
                if (x < i - 1) {
                    color_config[num] += `${x * 10}:${x * 10};`;
                } else {
                    color_config[num] += `${x * 10}:${x * 10}`;
                }
            }
        }

        return color_config;
    }


    static RemoveSmallChipConfig() {
        let data = {};
        data["30"] = 20;
        data["40"] = 20;
        data["50"] = 20;
        data["60"] = 30;
        data["70"] = 30;
        data["80"] = 30;
        data["90"] = 30;
        data["100"] = 40;
        data["110"] = 40;
        data["120"] = 40;
        data["130"] = 50;
        data["140"] = 50;
        data["150"] = 50;
        data["160"] = 60;
        data["170"] = 60;
        data["180"] = 60;
        data["190"] = 70;
        data["200"] = 70;
        data["210"] = 70;
        data["220"] = 80;
        data["230"] = 80;
        data["240"] = 80;
        data["250"] = 90;
        data["260"] = 90;
        data["270"] = 90;
        data["280"] = 100;
        data["290"] = 100;
        data["300"] = 100;

        return data;
    }

    static UnlockSlotConfig() {
        let data = {
            "0": {
                "slot_id": 0,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "1": {
                "slot_id": 1,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "2": {
                "slot_id": 2,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "3": {
                "slot_id": 3,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "4": {
                "slot_id": 4,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "5": {
                "slot_id": 5,
                "unlock_type": 1,
                "unlock_value": 0
            },
            "6": {
                "slot_id": 6,
                "unlock_type": 1,
                "unlock_value": 60
            },
            "7": {
                "slot_id": 7,
                "unlock_type": 1,
                "unlock_value": 70
            },
            "8": {
                "slot_id": 8,
                "unlock_type": 1,
                "unlock_value": 80
            },
            "9": {
                "slot_id": 9,
                "unlock_type": 1,
                "unlock_value": 90
            },
            "10": {
                "slot_id": 10,
                "unlock_type": 1,
                "unlock_value": 100
            },
            "11": {
                "slot_id": 11,
                "unlock_type": 2,
                "unlock_value": 100
            }
        };

        return data;
    }


    /**
     * 保存游戏数据
     */
    static saveGameData(data: any) {
        // Log.Debug("[SimulationMgr] saveGameData : " + JSON.stringify(data));

        localStorage.setItem("game_data", JSON.stringify(data));
    }

    static onClickShuffleCard() {
        ReceiveEventManager.OnUseShuffleCardStatusEvent({ "status": true });
    }

    static unlockChipBox(slotType: number, slotId: number) {
        ReceiveEventManager.OnUnlockChipBoxStatusEvent({ "status": true, "type": slotType, "slotId": slotId });
    }

    static onShowUnlockChipBoxDialog(slotId: number) {
        SimulationMgr.unlockChipBox(1, slotId);
    }

    static OnGameReplayEvent() {
        ReceiveEventManager.OnGameReplayEvent();
    }
}