const setVals = () => {
  $('input[type=range]').each(function (ind, inp) {
    inp.setAttribute('value', inp.value);
    // Add or find indicator
    let indicator = inp.parentNode.querySelector('.range-value-indicator');
    if (!indicator) {
      indicator = document.createElement('span');
      indicator.className = 'range-value-indicator';
      indicator.style.cssText =
        'float:right; margin-left:10px; min-width:2em; text-align:right; font-weight:bold;';
      inp.parentNode.appendChild(indicator);
    }
    indicator.textContent = inp.value;
    // Update indicator when input changes
    inp.addEventListener('input', function () {
      indicator.textContent = inp.value;
    });
  });
};
