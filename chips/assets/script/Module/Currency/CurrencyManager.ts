import { Tools } from "../../Common/Tools";
import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";
import ResourceManager from "../../FrameWork/ResourceManager";
import { Country } from "../Language/Language";

/**
 * 货币配置接口
 */
interface CurrencyConfig {
    countryCode: string; // 国家代码
    currencyCode: string; // 货币代码
    symbol: string; // 货币符号
    exchangeRate: number; // 汇率
    decimalPlaces: number; // 小数位数
    thousandsSeparator: string; // 千分位分隔符
    decimalSeparator: string; // 小数分隔符
}

/**
 * 货币管理器 - 负责货币相关的所有逻辑
 * 包括汇率、货币符号、格式化、图标等
 */
export default class CurrencyManager {
    private static _instance: CurrencyManager;

    public static get instance(): CurrencyManager {
        if (!this._instance) {
            this._instance = new CurrencyManager();
        }
        return this._instance;
    }

    private currentCountry: Country = Country.EN;
    private currencyConfigs: { [key: string]: CurrencyConfig } = {};

    // 货币图标映射
    private readonly OneMoneyIconMap: { [key: string]: string } = {
        [Country.EN]: "Atlas/Icon/money/money",
        [Country.ID]: "Atlas/Icon/money/IDmoney",
        [Country.BR]: "Atlas/Icon/money/BRmoney",
        [Country.RU]: "Atlas/Icon/money/RUmoney",
        [Country.KR]: "Atlas/Icon/money/kr1",
        [Country.JP]: "Atlas/Icon/money/jp1",
        [Country.DE]: "Atlas/Icon/money/ouyuan1",
        [Country.MX]: "Atlas/Icon/money/mx1",
        [Country.CL]: "Atlas/Icon/money/cl1",
        [Country.CO]: "Atlas/Icon/money/co1",
        [Country.PE]: "Atlas/Icon/money/pe1",
        [Country.AR]: "Atlas/Icon/money/ar1",
        [Country.IN]: "Atlas/Icon/money/yindu1",
    };

    private readonly MoreMoneyIconMap: { [key: string]: string } = {
        [Country.EN]: "Atlas/Icon/money/Moremoney",
        [Country.ID]: "Atlas/Icon/money/IDMoremoney",
        [Country.BR]: "Atlas/Icon/money/BRMoremoney",
        [Country.RU]: "Atlas/Icon/money/RUMoremoney",
        [Country.KR]: "Atlas/Icon/money/kr2",
        [Country.JP]: "Atlas/Icon/money/jp2",
        [Country.DE]: "Atlas/Icon/money/ouyuan2",
        [Country.MX]: "Atlas/Icon/money/mx2",
        [Country.CL]: "Atlas/Icon/money/cl2",
        [Country.CO]: "Atlas/Icon/money/co2",
        [Country.PE]: "Atlas/Icon/money/pe2",
        [Country.AR]: "Atlas/Icon/money/ar2",
        [Country.IN]: "Atlas/Icon/money/yindu2",
    };

    /**
     * 初始化货币配置
     */
    public init(country: Country) {
        this.currentCountry = country;
        this.loadCurrencyConfig();
        Log.Debug("CurrencyManager init", this.currentCountry);
    }

    /**
     * 加载货币配置
     */
    private loadCurrencyConfig() {
        try {
            const config = ClientConfig.getConfig(ConfigKey.Currency);
            if (config) {
                this.currencyConfigs = config;
                Log.Debug("Currency config loaded successfully");
            } else {
                Log.Error("Failed to load currency config");
                this.initDefaultConfig();
            }
        } catch (error) {
            Log.Error("Error loading currency config:", error);
            this.initDefaultConfig();
        }
    }

    /**
     * 初始化默认配置（如果配置文件加载失败）
     */
    private initDefaultConfig() {
        this.currencyConfigs = {
            [Country.EN]: {
                countryCode: "en",
                currencyCode: "USD",
                symbol: "$",
                exchangeRate: 1,
                decimalPlaces: 2,
                thousandsSeparator: ",",
                decimalSeparator: "."
            }
        };
    }

    /**
     * 设置当前国家
     */
    public setCountry(country: Country) {
        this.currentCountry = country;
    }

    /**
     * 获取当前国家
     */
    public getCurrentCountry(): Country {
        return this.currentCountry;
    }

    /**
     * 获取汇率
     */
    public getExchangeRate(country?: Country): number {
        const targetCountry = country || this.currentCountry;
        const config = this.currencyConfigs[targetCountry];
        return config ? config.exchangeRate : 1;
    }

    /**
     * 获取货币符号
     */
    public getCurrencySymbol(country?: Country): string {
        const targetCountry = country || this.currentCountry;
        const config = this.currencyConfigs[targetCountry];
        return config ? config.symbol : "$";
    }

    /**
     * 获取单个货币图标路径
     */
    public getOneMoneyIcon(country?: Country): string {
        const targetCountry = country || this.currentCountry;
        return this.OneMoneyIconMap[targetCountry] || this.OneMoneyIconMap[Country.EN];
    }

    /**
     * 获取多个货币图标路径
     */
    public getMoreMoneyIcon(country?: Country): string {
        const targetCountry = country || this.currentCountry;
        return this.MoreMoneyIconMap[targetCountry] || this.MoreMoneyIconMap[Country.EN];
    }

    /**
     * 修改精灵的货币图标
     */
    public changeMoneyIcon(sp: cc.Sprite, country?: Country) {
        if (!sp || !cc.isValid(sp)) {
            Log.Error('CurrencyManager changeMoneyIcon: Sprite组件无效');
            return;
        }

        const iconPath = this.getOneMoneyIcon(country);
        if (!iconPath) {
            Log.Error('CurrencyManager changeMoneyIcon: 无法获取货币图标路径');
            return;
        }

        ResourceManager.loadRes(iconPath, cc.SpriteFrame, (frame: cc.SpriteFrame) => {
            if (frame && cc.isValid(sp)) {
                if (frame instanceof cc.SpriteFrame && frame.getTexture) {
                    sp.spriteFrame = frame;
                    Log.Debug(`CurrencyManager changeMoneyIcon 货币图标加载成功: ${iconPath}`);
                } else {
                    Log.Error(`CurrencyManager changeMoneyIcon 加载的资源不是有效的SpriteFrame: ${iconPath}`);
                }
            } else {
                Log.Error(`CurrencyManager changeMoneyIcon 货币图标加载失败: ${iconPath}`);
            }
        });
    }

    /**
     * 将美元金额转换为本地货币金额
     */
    public convertToLocalCurrency(usdAmount: number, country?: Country): number {
        const targetCountry = country || this.currentCountry;
        const exchangeRate = this.getExchangeRate(targetCountry);
        return Math.round(usdAmount * exchangeRate * 100) / 100;
    }

    /**
     * 格式化货币金额为字符串
     * @param usdAmount 美元金额
     * @param showSymbol 是否显示货币符号
     * @param country 目标国家（可选，默认使用当前国家）
     */
    public formatMoney(usdAmount: number, showSymbol: boolean = true, country?: Country): string {
        if (usdAmount == undefined || usdAmount == null) {
            return "";
        }

        const targetCountry = country || this.currentCountry;
        const config = this.currencyConfigs[targetCountry];

        if (!config) {
            Log.Error(`Currency config not found for country: ${targetCountry}`);
            return showSymbol ? `$${usdAmount}` : `${usdAmount}`;
        }

        // 转换为本地货币
        let localAmount = usdAmount * config.exchangeRate;

        // 根据配置的小数位数处理
        if (config.decimalPlaces === 0) {
            localAmount = Math.floor(localAmount);
        } else {
            localAmount = Tools.toFixed(localAmount, config.decimalPlaces);
        }

        // 格式化数字（添加千分位分隔符）
        let formattedAmount = this.formatNumber(localAmount, config);

        // 添加货币符号
        if (showSymbol) {
            // 特殊处理：欧元符号后面加空格
            if (config.symbol === "€" && targetCountry === Country.DE) {
                return `€ ${formattedAmount}`;
            }
            return `${config.symbol}${formattedAmount}`;
        }

        return formattedAmount;
    }

    /**
     * 格式化货币金额为字符串 只针对首页金额显示 规则
     *  货币符号1个单位，小数点1个单位，每一个数值都是1个单位
        1. 正常情况下，在没有自适应的前提下，总单位数量最多显示8位数（美术需要注意）
        2. 若总单位数量在9~11位时，不显示小数，只显示整数，按照K值走
        3. 若总单位数量在12位以上，不显示小数，只显示整数，按照M值走
     * @param usdAmount 美元金额
     * @param showSymbol 是否显示货币符号
     * @param country 目标国家（可选，默认使用当前国家）
     */
    public formatMoneyForHome(usdAmount: number, showSymbol: boolean = true, country?: Country): string {
        if (usdAmount == undefined || usdAmount == null) {
            return "";
        }

        const targetCountry = country || this.currentCountry;
        const config = this.currencyConfigs[targetCountry];

        if (!config) {
            Log.Error(`Currency config not found for country: ${targetCountry}`);
            return showSymbol ? `$${usdAmount}` : `${usdAmount}`;
        }

        // 转换为本地货币
        let localAmount = usdAmount * config.exchangeRate;
        const symbol = config.symbol;

        Log.Debug("CurrencyManager formatMoneyForHome", localAmount, symbol);

        // 先尝试正常格式化
        let formatted = this.formatMoney(usdAmount, showSymbol, targetCountry);
        let totalLength = formatted.length;

        Log.Debug("CurrencyManager formatMoneyForHome totalLength", totalLength, formatted);
        // 情况1: 8位数或以下，正常展示
        if (totalLength <= 8) {
            return formatted;
        }

        // 情况2: 9~11位数，取整数并使用K格式化
        if (totalLength >= 9 && totalLength <= 11) {
            const integerAmount = Math.floor(localAmount);
            return this.formatWithUnitForHome(integerAmount, symbol, showSymbol, "K");
        }

        // 情况3: 12位数或以上，取整数并使用M格式化
        if (totalLength >= 12) {
            const integerAmount = Math.floor(localAmount);
            return this.formatWithUnitForHome(integerAmount, symbol, showSymbol, "M");
        }

        Log.Debug("CurrencyManager formatMoneyForHome return", formatted);
        return formatted;
    }

    /**
     * 使用单位（K、M）格式化金额，用于首页显示
     * @param amount 金额
     * @param symbol 货币符号
     * @param showSymbol 是否显示货币符号
     * @param unit 单位（K或M）
     */
    private formatWithUnitForHome(amount: number, symbol: string, showSymbol: boolean, unit: "K" | "M"): string {
        let value: number;
        if (unit === "K") {
            value = amount / 1000;
        } else {
            value = amount / 1000000;
        }

        const integerValue = Math.floor(value);

        if (showSymbol) {
            // 特殊处理：欧元符号后面加空格
            if (symbol === "€") {
                return `€ ${integerValue}${unit}`;
            }
            return `${symbol}${integerValue}${unit}`;
        }

        return `${integerValue}${unit}`;
    }

    /**
     * 格式化数字（添加千分位分隔符）
     */
    private formatNumber(amount: number, config: CurrencyConfig): string {
        // 先使用 toFixed 固定小数位数（会自动补0）
        const fixedAmount = amount.toFixed(config.decimalPlaces);
        const parts = fixedAmount.split(".");

        // 对于大于等于10000的数字，添加千分位分隔符
        const integerPart = parseFloat(parts[0]);
        if (integerPart >= 10000 && config.thousandsSeparator) {
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, config.thousandsSeparator);
        }

        // 如果配置要求显示小数且有小数部分
        if (config.decimalPlaces > 0 && parts.length > 1) {
            return parts[0] + config.decimalSeparator + parts[1];
        }

        return parts[0];
    }

    /**
     * 转盘专用货币格式化
     * 总显示6位数（包括货币符号1位、小数点1位）
     * 1. 若为6位数或6位数以下，正常展示
     * 2. 若为7位数，则取整数值即可，如 $104,14 -> $104
     * 3. 若为8位数或以上，使用单位表示（K、M、B），只显示整数：
     *    - K（千）：如 $1004,14 -> 1K 或 $10004.1 -> 10K
     *    - M（百万）：如果K格式后超过6位，使用M，如 $1000000 -> 1M
     *    - B（十亿）：如果M格式后超过6位，使用B，如 $1000000000 -> 1B
     * @param usdAmount 美元金额
     * @param country 目标国家（可选，默认使用当前国家）
     */
    public formatMoneyForWheel(usdAmount: number, country?: Country): string {
        if (usdAmount == undefined || usdAmount == null) {
            return "";
        }

        const targetCountry = country || this.currentCountry;
        const config = this.currencyConfigs[targetCountry];

        if (!config) {
            Log.Error(`Currency config not found for country: ${targetCountry}`);
            return `$${usdAmount}`;
        }

        // 转换为本地货币
        let localAmount = usdAmount * config.exchangeRate;
        const symbol = config.symbol;

        // 先尝试正常格式化
        let formatted = this.formatMoney(localAmount, true, targetCountry);
        let totalLength = formatted.length;

        // 情况1: 6位数或以下，正常展示
        if (totalLength <= 6) {
            return formatted;
        }

        // 情况2: 7位数，取整数（去掉小数部分）
        if (totalLength === 7) {
            const integerAmount = Math.floor(localAmount);
            // 格式化整数，去掉小数部分
            let integerFormatted = this.formatMoney(integerAmount, true, targetCountry);
            // 去掉小数部分（如果有）
            if (config.decimalSeparator && integerFormatted.includes(config.decimalSeparator)) {
                integerFormatted = integerFormatted.split(config.decimalSeparator)[0];
            }
            // 如果整数格式化后还是超过6位，需要用K或M
            if (integerFormatted.length > 6) {
                return this.formatWithUnit(integerAmount, symbol);
            }
            return integerFormatted;
        }

        // 情况3: 8位数或以上，使用单位（K、M、B）
        return this.formatWithUnit(localAmount, symbol);
    }

    /**
     * 使用单位（K、M、B）格式化金额，确保不超过6位
     * @param amount 金额
     * @param symbol 货币符号
     */
    private formatWithUnit(amount: number, symbol: string): string {
        // 先尝试用K（千）
        const kValue = amount / 1000;
        const kInteger = Math.floor(kValue);
        let kFormatted = `${symbol}${kInteger}K`;

        // 如果K格式后不超过6位，返回
        if (kFormatted.length <= 6) {
            return kFormatted;
        }

        // 如果K格式后超过6位，尝试用M（百万）
        const mValue = amount / 1000000;
        const mInteger = Math.floor(mValue);
        let mFormatted = `${symbol}${mInteger}M`;

        // 如果M格式后不超过6位，返回
        if (mFormatted.length <= 6) {
            return mFormatted;
        }

        // 如果M格式后超过6位，尝试用B（十亿）
        const bValue = amount / 1000000000;
        const bInteger = Math.floor(bValue);
        let bFormatted = `${symbol}${bInteger}B`;

        // 如果B格式后不超过6位，返回
        if (bFormatted.length <= 6) {
            return bFormatted;
        }

        // 如果B格式后还是超过6位，截断B值
        const maxDigits = 6 - symbol.length - 1; // 减去符号和B
        const bStr = bInteger.toString();
        if (bStr.length > maxDigits) {
            const truncatedB = parseInt(bStr.substring(0, maxDigits));
            bFormatted = `${symbol}${truncatedB}B`;
        }

        return bFormatted;
    }

    /**
     * 获取货币配置信息（用于调试）
     */
    public getCurrencyConfig(country?: Country): CurrencyConfig | null {
        const targetCountry = country || this.currentCountry;
        return this.currencyConfigs[targetCountry] || null;
    }
}

