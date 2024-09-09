class MaskService {
    static lazyInstance = null;
    /**
     * A default instance of MaskService.
     */
    static get default() {
        if (this.lazyInstance == null) {
            // eslint-disable-next-line @typescript-eslint/no-use-before-define
            this.lazyInstance = new MaskServiceImpl(7, 11);
        }
        return this.lazyInstance;
    }
}
class MaskServiceImpl {
    lowLen;
    highLen;
    maskSymbol;
    /**
     * Initializes a new instance of the MaskService class.
     * @param lowLen Minimal chars to mask as one first and one last symbol
     * @param highLen Minimal chars to mask as two first and two last symbol
     * @param maskSymbol Mask symbol
     */
    constructor(lowLen, highLen, maskSymbol = '*') {
        if (lowLen < 2) {
            throw new Error('lowLen: Low length may not be lesser 2.');
        }
        if (highLen < 4) {
            throw new Error('highLen: High length may not be lesser 4.');
        }
        if (lowLen > highLen) {
            throw new Error('highLen: High length should not be less than Low length.');
        }
        if (maskSymbol.length !== 1) {
            throw new Error('maskSymbol: Mask symbol should be of length 1');
        }
        this.lowLen = lowLen;
        this.highLen = highLen;
        this.maskSymbol = maskSymbol;
    }
    maskApiSecret(apiKey) {
        return this.maskSensitiveDataByAsterisk(apiKey);
    }
    maskApiKey(apiSecret) {
        return this.maskSensitiveDataByAsterisk(apiSecret);
    }
    maskHttpHeaderValue(headerValue) {
        return this.maskSensitiveDataByAsterisk(headerValue);
    }
    maskUri(uri) {
        const url = !(uri instanceof URL) ? new URL(uri) : uri;
        const escapedPassword = url.password;
        if (escapedPassword != null && escapedPassword.length > 0) {
            const password = decodeURIComponent(escapedPassword);
            const maskedPassword = this.maskSensitiveDataByAsterisk(password);
            const escapedMaskedPassword = encodeURIComponent(maskedPassword);
            const maskedUri = new URL(url.toString());
            maskedUri.password = escapedMaskedPassword;
            if (uri instanceof URL) {
                return maskedUri;
            }
            return maskedUri.toString();
        }
        return uri; // No password
    }
    maskSensitiveDataByAsterisk(data) {
        const len = data.length;
        const maskSym = this.maskSymbol;
        if (len === this.lowLen) {
            return `${data[0]}${maskSym.repeat(len - 1)}`;
        }
        if (len > this.lowLen && len < this.highLen) {
            return `${data[0]}${maskSym.repeat(len - 2)}${data[data.length - 1]}`;
        }
        if (len === this.highLen) {
            return `${data.substring(0, 2)}${maskSym.repeat(len - 3)}${data[data.length - 1]}`;
        }
        if (len >= this.highLen) {
            return `${data.substring(0, 2)}${maskSym.repeat(len - 4)}${data.substring(data.length - 2)}`;
        }
        return maskSym.repeat(len);
    }
}
module.exports = {
    MaskService,
    MaskServiceImpl
};
