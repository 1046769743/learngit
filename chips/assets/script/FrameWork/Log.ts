const { ccclass } = cc._decorator;

@ccclass
export class Log extends cc.Component {
    static IsDebug = true;
    static Debug(...args: any[]) {
        let msg = args.join(" ");
        msg = "[Debug] " + msg;
        Log.Print(msg);
    }

    static Info(msg: string) {
        msg = "[Info] " + msg;
        Log.Print(msg);
    }

    static Warning(msg: string) {
        msg = "[Warning] " + msg;
        // 黄色
        msg = "\x1b[33m" + msg + "\x1b[0m";
        Log.Print(msg);
    }

    static Error(msg: string, error: Error = null) {
        Log.ErrorStack(error, msg);
    }

    /**
     * 打印错误堆栈
     * @param error 错误对象或错误消息
     * @param context 上下文信息（可选）
     */
    static ErrorStack(error: any, context: string = "") {
        let errorMsg = "";
        let stack = "";

        if (error instanceof Error) {
            errorMsg = error.message;
            stack = error.stack || "";
        } else if (typeof error === "string") {
            errorMsg = error;
            // 尝试获取调用堆栈
            try {
                throw new Error();
            } catch (e: any) {
                stack = e.stack || "";
            }
        } else {
            errorMsg = String(error);
        }

        let logMsg = "[Error Stack]";
        if (context) {
            logMsg += ` [${context}]`;
        }
        logMsg += ` ${errorMsg}`;

        Log.Print("\x1b[31m" + logMsg + "\x1b[0m");
        if (stack) {
            // 格式化堆栈信息
            let stackLines = stack.split('\n');
            // 限制堆栈行数，避免输出过长
            let maxStackLines = 200;
            let displayStack = stackLines.slice(0, maxStackLines).join('\n');
            if (stackLines.length > maxStackLines) {
                displayStack += `\n... (还有 ${stackLines.length - maxStackLines} 行未显示)`;
            }
            Log.Print("\x1b[31m" + displayStack + "\x1b[0m");
        }
    }

    private static Print(msg: string): void {
        if (Log.IsDebug) {
            console.log(msg);
        }
    }
}

