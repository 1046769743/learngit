import { Tools } from '../../Common/Tools';
import ClientConfig from '../../Data/ClientConfig';
import { Log } from '../../FrameWork/Log';
import { UIManager } from '../../FrameWork/UIManager';
import { GameMgr } from '../Game/GameMgr';
import { LoadingStep } from './LoadingStep';

const { ccclass, property } = cc._decorator;

@ccclass
export class StepInitRes extends LoadingStep {
    onStart() {
        Log.Debug("StepInitRes onStart time = " + (new Date().getTime() - Tools.startTime));
        Log.Debug("StepInitRes onStart");
        ClientConfig.init();

    }

    onFrame(deltaTime: number) {
        if (UIManager.Instance != null && UIManager.Instance.isInitOk && ClientConfig.isInitOk) {
            this.onEnd();
        }
    }

    onEnd() {
        Log.Debug("StepInitRes onEnd time = " + (new Date().getTime() - Tools.startTime));
        this.IsOver = true;
        Log.Debug("StepInitRes onEnd");
    }
}

