import { EventName } from "./Common/EventName";
import { Tools } from "./Common/Tools";
import { EventCenter } from "./FrameWork/EventCenter";
import { Log } from "./FrameWork/Log";
import DailyLoginMgr from "./Module/DailyLogin/DailyLoginMgr";
import { GuideMgr } from "./Module/Guide/GuideMgr";
import { LoadingStep } from "./Module/Loading/LoadingStep";
import { StepInitData } from "./Module/Loading/StepInitData";
import { StepInitGame } from "./Module/Loading/StepInitGame";
import { StepInitRes } from "./Module/Loading/StepInitRes";
import { NativeApi } from "./Platform/Android/NativeApi";

const { ccclass, property } = cc._decorator;

@ccclass
export class Launcher extends cc.Component {
    private _loadingSteps: LoadingStep[] = []; // 加载步骤

    private _currentStepIndex: number = 0; // 当前加载步骤索引
    private _currentStep: LoadingStep = null; // 当前加载步骤

    start() {
        Log.Debug("Launcher start time1 = " + (new Date().getTime() - Tools.startTime));

        // cc.debug.setDisplayStats(true);
        Log.IsDebug = NativeApi.instance.getDebugBuild();

        // 设置全局错误处理
        this.setupGlobalErrorHandler();

        this._loadingSteps.push(new StepInitRes()); // 初始化配置
        this._loadingSteps.push(new StepInitData()); // 初始化数据
        this._loadingSteps.push(new StepInitGame()); // 初始化游戏

        this.startLoading(0);

        // NativeApi.instance.onGameInitFinished();
        Log.Debug("Launcher start time = " + new Date().getTime());
    }

    /**
     * 设置全局错误处理器
     * 捕获未处理的错误和 Promise 错误
     */
    private setupGlobalErrorHandler(): void {
        // 捕获未处理的 JavaScript 错误
        if (typeof window !== 'undefined') {
            window.onerror = (message, source, lineno, colno, error) => {
                Log.ErrorStack(error || new Error(String(message)), `GlobalError: ${source}:${lineno}:${colno}`);
                // 返回 false 表示不阻止默认的错误处理
                return false;
            };

            // 捕获未处理的 Promise 错误
            window.addEventListener('unhandledrejection', (event) => {
                Log.ErrorStack(event.reason, "UnhandledPromiseRejection");
            });
        }
    }

    update(deltaTime: number) {
        if (this._currentStep) {
            if (this._currentStep.IsOver) {
                this.onStepOver()
            } else {
                this._currentStep.onFrame(deltaTime);
            }
        }

        if (GuideMgr.Instance.isInitOk) {
            GuideMgr.Instance.update(deltaTime);
        }

        if (DailyLoginMgr.Instance.isInitOk) {
            DailyLoginMgr.Instance.update(deltaTime);
        }
    }

    private startLoading(index: number) {
        this._currentStepIndex = index;
        this._currentStep = this._loadingSteps[this._currentStepIndex];

        Log.Debug(`startLoading: ${this._currentStepIndex}`);

        this._currentStep.onStart();
    }

    private onStepOver() {
        this._currentStepIndex++;
        if (this._currentStepIndex < this._loadingSteps.length) {
            this.startLoading(this._currentStepIndex);
        } else {
            this._currentStep = null;
            this._currentStepIndex = -1;
        }
    }
}

