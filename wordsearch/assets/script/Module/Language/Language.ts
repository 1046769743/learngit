import ClientConfig, { ConfigKey } from "../../Data/ClientConfig";
import { Log } from "../../FrameWork/Log";

export enum LanguageType {
    /** 英文*/
    EN = "en",
    /** 俄语*/
    RU = "ru",
    /** 印尼语*/
    IN = "in",
    /** 韩国语*/
    KO = "ko",
    /** 日语*/
    JA = "ja",
    /** 葡萄牙语*/
    PT = "pt",
    /** 西班牙语*/
    ES = "es",
    /** 法国语*/
    FR = "fr",
    /** 德语*/
    DE = "de",
    /** 印度语*/
    HI = "hi",
}

export enum Country {
    /**印尼 */
    ID = "id",
    /**巴西 */
    BR = "br",
    /**巴基斯坦 */
    PK = "pk",
    /** 英语*/
    EN = "en",
    /** 英语*/
    US = "us",
    /** 俄罗斯*/
    RU = "ru",
    /** 韩国*/
    KR = "kr",
    /** 日本*/
    JP = "jp",
    /** 德国*/
    DE = "de",
    /** 墨西哥*/
    MX = "mx",
    /** 智利*/
    CL = "cl",
    /** 哥伦比亚*/
    CO = "co",
    /** 秘鲁*/
    PE = "pe",
    /** 阿根廷*/
    AR = "ar",
    /** 印度*/
    IN = "in",
    /** 葡萄牙*/
    PT = "pt",
    /** 西班牙*/
    ES = "es",
    /** 法国*/
    FR = "fr",
    /** 意大利*/
    IT = "it",
}

export default class Language {
    private static _instance: Language;
    public static get instance(): Language {
        if (!this._instance) {
            this._instance = new Language();
        }
        return this._instance;
    }

    private currentCountry: Country = Country.EN;
    private currentLanguage: LanguageType = LanguageType.EN;

    public init(language: LanguageType, country: Country) {
        this.currentLanguage = language;
        this.currentCountry = country;
        Log.Debug("Language init", this.currentCountry, this.currentLanguage);
    }

    public getCurrentCountry(): Country {
        return this.currentCountry;
    }

    public getCurrentLanguage(): LanguageType {
        return this.currentLanguage;
    }

    public getDes(key: string): string {
        // Log.Debug("Language getDes key: " + key + " currentLanguage: " + this.currentLanguage);
        let cfg = ClientConfig.getConfig(ConfigKey.Language);
        if (!cfg) {
            Log.Error('Language getDes: 无法获取配置');
            return '';
        }
        if (!cfg[key]) {
            Log.Error('Language getDes: 无法获取配置 key: ' + key);
            return '';
        }

        if (cfg[key][this.currentLanguage]) {
            return cfg[key][this.currentLanguage];
        } else {
            Log.Error('Language getDes: 无法获取配置 key: ' + key + " currentLanguage: " + this.currentLanguage);
            return '';
        }
    }
}