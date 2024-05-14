/*
 * Authenty AE - Bom Princípio-RS  |  github.com/authentyAE
 * by: will.i.am                   |  github.com/williampilger
 *
 * 2024.05.14 - Bom Princípio - RS
 * ♪ - / -
 *  
 * Class responsible for ... .
 * 
 */

export type alternativeType_SampleClass = {
    prop: string
}
export type anyType_SampleClass = SampleClass | alternativeType_SampleClass;

export class SampleClass {

    private _prop: string = 'sample';

    private _cache_length?:number; //this is a ridiculous sample of a cache for a property

    constructor(data?: alternativeType_SampleClass) {
        if( data ){
            this.prop = data.prop;
        }
    }

    // ========================= [ GETTERS / SETTERS ] =========================

    set prop(value: string) {
        this._prop = value;
        this._clearCache();
    }
    get prop(): string{
        return this._prop;
    }

    // ============================= [ PROPERTIES ] ============================

    get length(): number{
        if( this._cache_length === undefined ){
            this._cache_length = this.prop.length;
        }
        return this._cache_length;
    }

    // ========================== [ PUBLIC FUNCTIONS ] =========================
    // ========================= [ PRIVATE FUNCTIONS ] =========================

    // ============================= [ DISPLAYERS ] ============================

    toJSON() {
        return {
            prop: this.prop
        };
    }

    // ============================= [ HANDLERS ] ==============================

    static import(value: anyType_SampleClass): SampleClass{
        if( value instanceof SampleClass ){
            return value;
        } else {
            return new SampleClass(value);
        }
    }
    
    // ======================== [ INTERNAL UTILITIES ] =========================
    
    private _clearCache():void {
        this._cache_length = undefined;
    }
}
