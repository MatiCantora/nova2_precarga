
function tImage()
  {
  this.items = {}
  this.onError_Default = null
  this.onError_msg = "Imagen no encontrada"
  this.onError = null
  this.onComplete = null
  this.load = tImage_load;
  this.loadArray = tImage_loadArray;
  this.Exists = tImage_Exists;
  this.getImagenes = tImage_getImagenes;
  }

  function tImage_load(name, url, preLoad)
    {
    if (preLoad == undefined)
      preLoad = true
    var image 
    image = {}
    image.src = url;
    this.items[name] = image
    var My = this
    if (preLoad || this.onError_msg != null || this.onError_Default != null || this.onError != null || this.onComplete != null)
      {
      image = new Image();
      image.onload = function() 
                        {
                        My.items[name] = image
                        if (this.onComplete != null)
                          this.onComplete(My, image)
                        }
      image.onerror = function()
                        {
                        if (My.onError_Default != null)
                          {
                          var i = new Image();
                          i.src = My.onError_Default
                          My.items[name] = i
                          }
                          
                        if (My.onError_msg != null)
                          alert(My.onError_msg + "\nName: '" + name + "', URL: '" +  image.src + "'")
                        
                        if (this.onError != null)
                          this.onError(My, image)
                        }
      image.src = url;
      }
    }

  function tImage_Exists(name)
    {
    return this.items["name"] != undefined
    }

  function tImage_loadArray(Imagenes)
    {
    for (var name in Imagenes)
      {
      this.load(name, Imagenes[name].src)
      }
    }

  function tImage_getImagenes()
    {
    return this.items
    }