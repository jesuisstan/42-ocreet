document.addEventListener('DOMContentLoaded', function () {
  setVals();

  // Theme toggle logic
  const themeBtn = document.querySelector('.theme-toggle-btn');
  if (themeBtn) {
    themeBtn.addEventListener('click', () => {
      document.body.classList.toggle('theme-dark');
      // Save theme to localStorage
      localStorage.setItem(
        'theme',
        document.body.classList.contains('theme-dark') ? 'dark' : 'light'
      );
    });
  }
  // Restore theme on page load
  if (localStorage.getItem('theme') === 'dark') {
    document.body.classList.add('theme-dark');
  }
});

// setVals function for range value indicators
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
