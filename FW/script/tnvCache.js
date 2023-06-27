function tnvCache()
  {
  this.caches = {}
  this.add = tnvCache_add
  this.get = tnvCache_get
  this.findIndex = tnvCache_findIndex
  this.clear = tnvCache_clear
  }

function tnvCache_clear(cacheID)
  {
  if (cacheID == undefined)
    this.caches = {}
  else 
    this.caches[cacheID] = new Array()
      
  }
function tnvCache_findIndex(cacheID, params)
  {
  if (this.caches[cacheID] == undefined)
    return null
  var encontrado  
  var param
  var cache
  var caches = this.caches[cacheID]
  for (var i = 0; i < caches.size(); i++)
    {
    cache = caches[i]
    encontrado = true
    for (param in cache)
    if (param != 'valor' && param != 'valores' && param != 'expireAbsolute' && cache[param] != params[param])
      {
        if (typeof cache[param] == 'object' && typeof params[param] == 'object') {
            for (paramKey in cache[param]) {
                if (params[param][paramKey] != cache[param][paramKey]) {
                    encontrado = false
                    break
                }
            }  
        } else {
                encontrado = false
        }
        break
      }
    if (encontrado)
      return i
    }
  return null      
  }
  
function tnvCache_add(cacheID, params, valores, expire_minutes, expireAbsolute)
  {
  if (expire_minutes > 0)
    {
    var h = new Date()
    expireAbsolute = new Date(h.getTime() + (expire * 1000 * 60))
    }
    
  if (typeof(expireAbsolute) != 'date')
    expireAbsolute = null  
   
  if (!this.caches[cacheID])
    this.caches[cacheID] = new Array()
    
  var index = this.findIndex(cacheID, params)
  if (index == null)
    index = this.caches[cacheID].size()
  
  this.caches[cacheID][index] = {}
  var cache = this.caches[cacheID][index]
  
  for (var param in params)
    cache[param] = params[param]
    
  if(typeof(params) == 'object')
    {
    cache['valores'] = {}
    for (var valor in valores)
      cache['valores'][valor] = valores[valor]
    }
  else
    cache['valor'] = valor
    
  return cache
  }
  
function tnvCache_get(cacheID, params)
  {
  var i = this.findIndex(cacheID, params)
  if (i != null)
    return this.caches[cacheID][i]
  else
    return null  
  }
