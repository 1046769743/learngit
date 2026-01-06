// Learn TypeScript:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/typescript.html
// Learn Attribute:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/reference/attributes.html
// Learn life-cycle callbacks:
//  - https://docs.cocos.com/creator/2.4/manual/en/scripting/life-cycle-callbacks.html

import { ObjectPoolManager } from "../../Common/ObjectPoolManager";
import { Log } from "../../FrameWork/Log";
import { GameMgr } from "../../Module/Game/GameMgr";

const { ccclass, property } = cc._decorator;

/**
 * 锚点类型枚举
 */
enum AnchorType {
    LeftCenter = 0,   // 左中心 (0, 0.5)
    Center = 1        // 中心 (0.5, 0.5)
}

/**
 * 方向信息接口
 */
interface DirectionInfo {
    angle: number;           // 旋转角度
    offsetX: number;         // X偏移（基于单位长度）
    offsetY: number;         // Y偏移（基于单位长度）
}

@ccclass
export default class ItemSelectEffect extends cc.Component {

    @property(cc.Sprite)
    sprite: cc.Sprite = null;

    private startPosition: cc.Vec2 = null;
    private breathTween: cc.Tween = null;

    private NODE_HEIGHT = 80;  // 固定高度
    private DEFAULT_WIDTH = 80; // 默认宽度

    private scale = 1;
    private updateNodeSize() {
        let grid = GameMgr.Instance.getCurrentWordSearchGameData().gridSize;

        if (grid.rows == 4 || grid.cols == 4) {
            this.NODE_HEIGHT = 100;
            this.DEFAULT_WIDTH = 100;
            this.scale = 1.25;
        } else if (grid.rows == 5 || grid.cols == 5) {
            this.NODE_HEIGHT = 80;
            this.DEFAULT_WIDTH = 80;
            this.scale = 1;
        } else if (grid.rows == 6 || grid.cols == 6) {
            this.NODE_HEIGHT = 80;
            this.DEFAULT_WIDTH = 80;
            this.scale = 1;
        }

        this.node.scale = this.scale;
    }

    /**
     * 获取方向信息（角度和单位偏移）
     * @param direction 方向向量
     * @returns 方向信息
     */
    private getDirectionInfo(direction: cc.Vec2): DirectionInfo {
        const sqrt2 = Math.sqrt(2);

        // 映射所有8个方向
        const directionMap: { [key: string]: DirectionInfo } = {
            '0,0': { angle: 0, offsetX: 0, offsetY: 0 },           // 原地
            '1,0': { angle: 0, offsetX: 1, offsetY: 0 },           // 右
            '1,1': { angle: 45, offsetX: 1 / sqrt2, offsetY: 1 / sqrt2 },   // 右上
            '0,1': { angle: 90, offsetX: 0, offsetY: 1 },          // 上
            '-1,1': { angle: 135, offsetX: -1 / sqrt2, offsetY: 1 / sqrt2 }, // 左上
            '-1,0': { angle: 180, offsetX: -1, offsetY: 0 },       // 左
            '-1,-1': { angle: 225, offsetX: -1 / sqrt2, offsetY: -1 / sqrt2 }, // 左下
            '0,-1': { angle: 270, offsetX: 0, offsetY: -1 },       // 下
            '1,-1': { angle: 315, offsetX: 1 / sqrt2, offsetY: -1 / sqrt2 }  // 右下
        };

        const key = `${direction.x},${direction.y}`;
        return directionMap[key] || directionMap['0,0'];
    }

    /**
     * 计算左中心锚点的起始位置
     * @param position 基准位置
     * @param direction 方向向量
     * @param halfHeight 节点高度的一半
     * @returns 起始位置
     */
    private calculateLeftCenterPosition(position: cc.Vec2, direction: cc.Vec2, halfHeight: number): cc.Vec2 {
        const dirInfo = this.getDirectionInfo(direction);

        // 原地不动的特殊情况
        if (direction.x === 0 && direction.y === 0) {
            return cc.v2(position.x - halfHeight, position.y);
        }

        // 计算起始位置偏移
        const startX = position.x - dirInfo.offsetX * halfHeight;
        const startY = position.y - dirInfo.offsetY * halfHeight;

        return cc.v2(startX, startY);
    }

    /**
     * 计算中心锚点的位置
     * @param position 基准位置
     * @param direction 方向向量
     * @param halfHeight 节点高度的一半
     * @param halfWidth 节点宽度的一半
     * @returns 中心位置
     */
    private calculateCenterPosition(position: cc.Vec2, direction: cc.Vec2, halfHeight: number, halfWidth: number): cc.Vec2 {
        const dirInfo = this.getDirectionInfo(direction);

        // 原地不动的特殊情况
        if (direction.x === 0 && direction.y === 0) {
            return cc.v2(position.x, position.y);
        }

        // 从左边缘偏移到中心：先到左边缘，再向方向移动halfWidth
        const leftEdgeX = position.x - dirInfo.offsetX * halfHeight;
        const leftEdgeY = position.y - dirInfo.offsetY * halfHeight;

        // 计算从左边缘到中心的偏移
        const angleRad = dirInfo.angle * Math.PI / 180;
        const centerX = leftEdgeX + halfWidth * Math.cos(angleRad);
        const centerY = leftEdgeY + halfWidth * Math.sin(angleRad);

        return cc.v2(centerX, centerY);
    }

    /**
     * 应用效果配置
     * @param position 位置
     * @param angle 角度
     * @param width 宽度
     * @param height 高度
     * @param anchorType 锚点类型
     */
    private applyEffectConfig(position: cc.Vec2, angle: number, width: number, height: number, anchorType: AnchorType) {
        // 设置锚点
        if (anchorType === AnchorType.LeftCenter) {
            this.node.anchorX = 0;
            this.node.anchorY = 0.5;
        } else {
            this.node.anchorX = 0.5;
            this.node.anchorY = 0.5;
        }

        // 设置大小和位置
        width = Math.max(width, this.DEFAULT_WIDTH);
        this.node.width = width / this.scale;
        // this.node.height = height  this.scale;
        this.node.angle = angle;
        this.node.position = new cc.Vec3(position.x, position.y, 0);
        // this.node.scale = 1;
    }

    /**
     * 设置初始位置（用于选择开始）
     * @param position 起始单元格的中心位置
     * @param startCell 起始单元格坐标（可选）
     */
    public setPosition(position: cc.Vec2, startCell: cc.Vec2) {
        this.updateNodeSize();
        this.startPosition = position;
        this.node.anchorX = 0.5;
        this.node.anchorY = 0.5;
        // const halfHeight = this.NODE_HEIGHT / 2;
        const startPos = cc.v2(position.x, position.y);

        this.applyEffectConfig(startPos, 0, this.NODE_HEIGHT, this.NODE_HEIGHT, AnchorType.Center);
    }

    /**
     * 设置长度和方向（用于选择中，锚点为左中）
     * @param length 效果线的长度
     * @param direction 方向向量
     */
    public setLengthAndDirection(length: number, direction: cc.Vec2) {
        this.updateNodeSize();
        const halfHeight = this.NODE_HEIGHT / 2;
        const dirInfo = this.getDirectionInfo(direction);

        // 计算宽度
        const width = (direction.x === 0 && direction.y === 0)
            ? this.DEFAULT_WIDTH
            : length + halfHeight;

        // 计算起始位置
        const startPos = this.calculateLeftCenterPosition(this.startPosition, direction, halfHeight);

        // 应用配置
        this.applyEffectConfig(startPos, dirInfo.angle, width, this.NODE_HEIGHT, AnchorType.LeftCenter);
    }

    /**
     * 播放提示呼吸动画（锚点为中心）
     * @param position 起始单元格的中心位置
     * @param length 效果线的长度
     * @param direction 方向向量
     */
    public playBreathEffect(position: cc.Vec2, length: number, direction: cc.Vec2, color: cc.Color) {
        this.stopBreathEffect();
        this.startPosition = position;

        this.applyBreathOrFinishEffect(position, length, direction, true, color);
    }

    /**
     * 显示完成效果（锚点为中心，无动画）
     * @param position 起始单元格的中心位置
     * @param length 效果线的长度
     * @param direction 方向向量
     */
    public playFinishEffect(position: cc.Vec2, length: number, direction: cc.Vec2, color: cc.Color) {
        this.startPosition = position;
        this.applyBreathOrFinishEffect(position, length, direction, false, color);
    }

    /**
     * 应用呼吸或完成效果的通用逻辑
     * @param position 起始位置
     * @param length 长度
     * @param direction 方向
     * @param withAnimation 是否带动画
     */
    private applyBreathOrFinishEffect(position: cc.Vec2, length: number, direction: cc.Vec2, withAnimation: boolean, color: cc.Color) {
        this.updateNodeSize();
        const halfHeight = this.NODE_HEIGHT / 2;
        const dirInfo = this.getDirectionInfo(direction);

        this.sprite.node.color = color;

        // 计算宽度
        const width = (direction.x === 0 && direction.y === 0)
            ? this.DEFAULT_WIDTH
            : length + this.NODE_HEIGHT;

        const halfWidth = width / 2;

        // 计算中心位置
        const centerPos = this.calculateCenterPosition(position, direction, halfHeight, halfWidth);

        // 应用配置
        this.applyEffectConfig(centerPos, dirInfo.angle, width, this.NODE_HEIGHT, AnchorType.Center);

        // 如果需要动画，启动呼吸效果
        if (withAnimation) {
            this.breathTween = cc.tween(this.node)
                .to(0.8, { scale: 1.05 }, { easing: 'sineInOut' })
                .to(0.8, { scale: 1 }, { easing: 'sineInOut' })
                .union()
                .repeatForever()
                .start();
        }
    }

    /**
     * 停止呼吸动画
     */
    public stopBreathEffect() {
        if (this.breathTween) {
            this.breathTween.stop();
            this.breathTween = null;
        }
        this.node.scale = 1;

        // 如果锚点是中心点，恢复到左中
        if (this.node.anchorX === 0.5) {
            const currentPos = this.node.getPosition();
            const currentWidth = this.node.width;
            const currentAngle = this.node.angle;

            // 计算从中心锚点到左中锚点的位置偏移
            const angleRad = currentAngle * Math.PI / 180;
            const offsetX = (currentWidth / 2) * Math.cos(angleRad);
            const offsetY = (currentWidth / 2) * Math.sin(angleRad);

            this.node.anchorX = 0;
            this.node.anchorY = 0.5;
            this.node.setPosition(currentPos.x - offsetX, currentPos.y - offsetY);
        }
    }

    /**
     * 设置颜色
     * @param color 颜色
     */
    public setColor(color: cc.Color) {
        this.sprite.node.color = color;
    }

    /**
     * 设置节点大小
     * @param size 大小
     */
    public setSize(size: cc.Size) {
        this.node.setContentSize(size);
    }

    /**
     * 回收节点到对象池
     */
    public recycle() {
        this.stopBreathEffect();
        ObjectPoolManager.instance.putNode(this.node);
    }

    /**
     * 组件销毁时停止动画
     */
    onDestroy() {
        this.stopBreathEffect();
    }
}
