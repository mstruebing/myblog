var navBar = document.getElementById('nav');

document.addEventListener('scroll', function() {
  if (window.scrollY > 50) {
    navBar.classList.add('shrink');
  } else {
    navBar.classList.remove('shrink');
  }
})

var navButton = document.getElementById('navButton');
var navBar = document.getElementById('navBar');

navButton.addEventListener('click', function() {
  navBar.classList.toggle('collapse');
});
