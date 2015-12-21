var navBar = document.getElementById('nav');

document.addEventListener('scroll', function() {
  if (window.scrollY > 50) {
    navBar.classList.add('shrink');
  } else {
    navBar.classList.remove('shrink');
  }
})
