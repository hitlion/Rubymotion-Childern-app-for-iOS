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

/* add a remove() prototype to Array objects 
 * Credits to: http://stackoverflow.com/a/3955096/12866
 */
Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};

