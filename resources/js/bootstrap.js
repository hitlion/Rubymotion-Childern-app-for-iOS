function __CacheProxy(cache) { this._cache = cache; }

__CacheProxy.prototype = {
  construct: function() {
    var props = this._cache.props;
    for( var p in props ) {
      if( props[p].indexOf('__fn_') == 0 ) {
        continue;
      }
      this.export(props[p]);
    }
    return this;
  },

  export: function(name) {
    this.__defineGetter__(name, function(){
      var value = this._cache.get(name);

      if( value != undefined && typeof value == 'string' && value.indexOf('__fn_') == 0 ) {
        if( this.hasOwnProperty(value) == false ) {
          this['__fn_' + name] = eval('(function(){ return ' + this._cache.get('__fn_' + name) + '; }())');
        }
        return this['__fn_' + name];
      }
      return value;
    });

    this.__defineSetter__(name, function(value){
      if( typeof value == 'function' ) {
        this._cache.set('__fn_' + name, value.toString());
        return this._cache.set(name, '__fn_' + name);
      }
      return this._cache.set(name, value);
    });

    var generator = function(proxy, property){
      return { get _() { return proxy[property] },
        set _(value) { proxy[property] = value; } };
    };
    return generator(this, name);
  }
}

$$ = new __CacheProxy($$).construct();

