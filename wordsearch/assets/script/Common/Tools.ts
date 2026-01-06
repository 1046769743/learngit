import { Log } from '../FrameWork/Log';
const { ccclass, property } = cc._decorator;

@ccclass
export class Tools {
    static startTime = 0;


    // [10,20,15,5,10,20,15,5]
    // 需要根据权重随机出一个数
    static getRandomByWeight(weightList: number[]): number {
        if (!weightList || weightList.length === 0) {
            return -1;
        }

        // 计算总权重
        let totalWeight = 0;
        for (let i = 0; i < weightList.length; i++) {
            totalWeight += weightList[i];
        }

        if (totalWeight <= 0) {
            return 0; // 如果总权重为0或负数，返回第一个索引
        }

        // 生成0到totalWeight之间的随机数
        let random = Math.random() * totalWeight;

        // 遍历权重列表，找到随机数落在哪个区间
        let currentWeight = 0;
        for (let i = 0; i < weightList.length; i++) {
            currentWeight += weightList[i];
            if (random < currentWeight) {
                return i;
            }
        }

        // 理论上不会到这里，但为了安全返回最后一个索引
        return weightList.length - 1;
    }

    static getWeightList(str: string) {
        var arr = str.split(";");
        var config = {};
        for (var i = 0; i < arr.length; i++) {
            var item = arr[i];
            var item_arr = item.split(":");
            config[parseInt(item_arr[0])] = parseInt(item_arr[1]);
        }

        var weightList = [];
        for (var key in config) {
            let num = config[key];
            for (let i = 0; i < num; i++) {
                weightList.push(parseInt(key));
            }
        }

        return weightList;
    }

    /**
     * 获取标准方向（8个方向之一）
     */
    static getStandardDirection(startDirection: cc.Vec2, endDirection: cc.Vec2): cc.Vec2 {
        // 距离小于100，返回原地
        const dx = endDirection.x - startDirection.x;
        const dy = endDirection.y - startDirection.y;
        if (Math.sqrt(dx * dx + dy * dy) < 40) {
            return cc.v2(0, 0);
        }

        // 如果向量为零，返回原地
        if (dx === 0 && dy === 0) {
            return cc.v2(0, 0);
        }

        // 计算角度（弧度）- 左下角坐标系，y轴向上
        const angle = Math.atan2(dy, dx);
        // 转换为角度（0-360度）
        let degrees = (angle * 180 / Math.PI + 360) % 360;

        // 将圆八等分，每个方向45度

        if (degrees >= 337.5 || degrees < 22.5) {
            return cc.v2(1, 0);   // 右
        } else if (degrees >= 22.5 && degrees < 67.5) {
            return cc.v2(1, 1);   // 右上
        } else if (degrees >= 67.5 && degrees < 112.5) {
            return cc.v2(0, 1);   // 上
        } else if (degrees >= 112.5 && degrees < 157.5) {
            return cc.v2(-1, 1);  // 左上
        } else if (degrees >= 157.5 && degrees < 202.5) {
            return cc.v2(-1, 0);  // 左
        } else if (degrees >= 202.5 && degrees < 247.5) {
            return cc.v2(-1, -1); // 左下
        } else if (degrees >= 247.5 && degrees < 292.5) {
            return cc.v2(0, -1);  // 下
        } else {
            return cc.v2(1, -1);  // 右下
        }
    }

    // 通用的保留N位小数的方法，参数1 数字，参数2 保留的小数位数
    static toFixed(num: number, digits: number = 2, isFloor: boolean = false): number {
        if (isNaN(num)) {
            return 0;
        }
        if (isFloor) {
            return Math.floor(num * Math.pow(10, digits)) / Math.pow(10, digits);
        } else {
            return Math.round(num * Math.pow(10, digits)) / Math.pow(10, digits);
        }
    }

    // 保留N位小数并返回字符串（用于显示）
    static toFixedString(num: number, digits: number = 2): string {
        if (isNaN(num)) {
            return '0';
        }
        return num.toFixed(digits);
    }

    // 判断是否跨天
    static isCrossDay(lastTime: number, now: number): boolean {
        if (lastTime == 0) {
            return true;
        }
        if (lastTime > now) {
            return false;
        }
        // 将时间戳转换为日期对象
        const lastDate = new Date(lastTime);
        const nowDate = new Date(now);

        // 比较年、月、日是否不同
        return lastDate.getFullYear() !== nowDate.getFullYear() ||
            lastDate.getMonth() !== nowDate.getMonth() ||
            lastDate.getDate() !== nowDate.getDate();
    }

    // 替换成艺术字的str 
    static replaceToBmfontString(str: string) {
        // . => &
        // R$ => Z
        // Rp => X
        // Rs => Y
        // S/ => S
        if (!str) {
            return str;
        }
        let result = str;
        result = result.replace(/\./g, '&');
        result = result.replace(/R\$/g, 'Z');
        result = result.replace(/Rp/g, 'X');
        result = result.replace(/Rs/g, 'Y');
        result = result.replace(/S\//g, 'S');
        return result;
    }
}
