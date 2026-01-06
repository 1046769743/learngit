const { ccclass } = cc._decorator;

@ccclass('EventCenter')
export class EventCenter {
    static handlers: Map<string, { handler: Function, target: any }[]> = new Map<string, { handler: Function, target: any }[]>();

    /**
     * 添加事件监听
     * @param eventName 
     * @param handler 
     * @param target 
     */
    public static on(eventName: string, handler: Function, target: any) {
        if (!EventCenter.handlers[eventName]) {
            EventCenter.handlers[eventName] = [];
        }

        EventCenter.handlers[eventName].push({ handler: handler, target: target });
    }

    /**
     * 移除事件监听
     * @param eventName 
     * @param handler 
     * @param target 
     */
    public static off(eventName: string, handler: Function, target: any) {
        if (!EventCenter.handlers[eventName]) {
            return;
        }

        let handlerList = EventCenter.handlers[eventName];
        for (let i = 0; i < handlerList.length; i++) {
            if (handlerList[i].handler == handler && handlerList[i].target == target) {
                handlerList.splice(i, 1);
                break;
            }
        }
    }

    /**
     * 发送事件
     * @param eventName 
     * @param args 
     */
    public static dispatchEvent(eventName: string, ...args: any[]) {
        if (!EventCenter.handlers[eventName]) {
            return;
        }

        // 构建参数列表
        const params = [];
        for (let i = 1; i < arguments.length; i++) {
            params.push(arguments[i]);
        }

        let handlerList = EventCenter.handlers[eventName];
        for (let i = 0; i < handlerList.length; i++) {
            if (handlerList[i] && handlerList[i].handler) {
                handlerList[i].handler.apply(handlerList[i].target, params);
            }
        }
    }
}