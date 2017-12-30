numVisible=2;
numActive=undefined;
numPrevious=undefined;
numDir=1;
function toggleSlides(d) 
{
  //console.log(d);

  var slides = $('.slide');
  var lastSlide = slides.length - 1;
  var legend = $('.legend');
  //console.log(numActive);
  if ( numActive === undefined ) 
  {
    for (var i = 0; i < numVisible; i++) 
    {
      slides[i].className = "slide active fl dib w-100 w-third-ns w-50-m pa2";
    }
    numActive = 0;
  } 
  else 
  {
    if ( d === 'interval' ) 
    { 
      d = numDir 
    } 
    else 
    { 
      clearInterval(refreshIntervalId); 
    }

    var skip = false;
    if (( d === -1 ) && (numActive === 0)) 
    { 
      numDir = 1; 
      skip = true; 
    }
    if (( d === 1 ) && (numActive === (lastSlide-numVisible-1))) 
    { 
      numDir = -1; 
      skip=true; 
    }
    if (skip === true) 
    { 
      numPrevious = numActive; 
      return; 
    }
    numActive += d;
    var show = numActive+numVisible-1;
    var hide = numActive-1;
    if (numPrevious > numActive) 
    {
      hide = numActive+numVisible;
      show = numActive;
    }
    console.log("hide: " + hide + " show: " + show);

    // This if else block scales the carousel width based on the number of slides in it 
    switch(numVisible){
      case 1:
        slides[hide].className = "slide dn fl w-100 w-100-ns w-50-m pa2";
        slides[show].className = "slide active fl w-100 w-100-ns w-50-m pa2";
        break;
      case 2:
        slides[hide].className = "slide dn fl w-100 w-50-ns w-50-m pa2";
        slides[show].className = "slide active fl w-100 w-50-ns w-50-m pa2";
        break;
      case 3:
        slides[hide].className = "slide dn fl w-100 w-third-ns w-50-m pa2";
        slides[show].className = "slide active fl w-100 w-third-ns w-50-m pa2";
        break;
      default:
        console.log("ERROR: toggleSlides: numVisible must be 1, 2 or 3, it is: " + numVisible);
        break;
    }

    legend[numPrevious].className = "legend o-100";
  }
  legend[numActive].className = "legend o-20";

  // Alternatively, use switchClass from jQueryUI?
  document.getElementById('btn-left').className = ( numActive === 0 ) ? "not-active o-20" : "o-100";
  document.getElementById('btn-right').className = ( numActive === (lastSlide-numVisible-1) ) ? "not-active o-20" : "o-100";
  numPrevious = numActive;
}
//toggleSlides('interval');
var refreshIntervalId =setInterval(function(){ toggleSlides('interval'); }, 5000);
