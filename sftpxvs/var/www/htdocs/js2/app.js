function showpass(a) {
  var e = a.nextElementSibling;
  e.type == 'password' ? e.type = 'text' : e.type = 'password';
}

function copy(a) {
  const area = a.parentElement.querySelector('.copy-source');
  area.select();
  document.execCommand('copy')
}

function scrollT() {
  $('html, body').animate({
    scrollTop: 0
  }, 500);
}


function loadT(a){
  var t = document.querySelector('.js-header');
  var d = document.createElement('h4');
  d.classList.add('mb-0');
  d.classList.add('text-dark');
  d.innerHTML = a;
  t.innerHTML = "";
  t.appendChild(d);
}

function openM(){
  var n = document.querySelector('.navpanel');
  n.classList.toggle('open');
  var d = document.createElement("div");
  d.classList.add('navpanel-backdrop');
  document.body.appendChild(d);

  document.addEventListener('click', function(e) {
    if(e.target.className == 'navpanel-backdrop') {
      n.classList.remove('open');
      d.remove();
    }
  });

  document.querySelector('.navpanel-close').addEventListener('click', function(e) {
      n.classList.remove('open');
      d.remove();
  });

}

function copy(a) {
  const area = a.parentElement.querySelector('.copy-source');
  area.select();
  document.execCommand('copy')
}


function navMenuTabs(a_link) {
 const tabEl = document.querySelectorAll('.navpanel-tabs a[data-bs-toggle="tab"]');
 tabEl.forEach((item, i) => {
   item.addEventListener('shown.bs.tab', event => {
     localStorage.setItem('nav_tab', event.target.hash);
   });
 });
 const activeTab = localStorage.getItem('nav_tab');
 if(a_link == true) {
   const tab = document.querySelector('a[href="#admin_menu"]');
   const bsTab = new bootstrap.Tab(tab);
   bsTab.show()
 } else if(activeTab) {
   const tab = document.querySelector('a[href="'+activeTab+'"]');
   const bsTab = new bootstrap.Tab(tab);
   bsTab.show()
 } else {
   const tab = document.querySelector('a[href="#user_menu"]');
   const bsTab = new bootstrap.Tab(tab);
   bsTab.show()
 }
}

$(document).ready(function(){


  $('.open-menu').on('click', openM);




var menuState = localStorage.getItem('menuState');

if (menuState) {
    $('.navpanel-menu .nav-link').each(function() {
        var href = $(this).attr('href');
        if (menuState.includes(href)) {
            $(this).addClass('open');
            $(this).next('.navpanel-submenu').slideDown();
        }
    });
}


$(".has-submenu").on('click', function(e) {
    e.preventDefault();
    $(this).toggleClass('open');
    var href = $(this).attr('href');
    var isActive = $(this).hasClass('open');

    if (isActive) {

        var currentState = localStorage.getItem('menuState');

        if (currentState) {
            var currentStateArray = currentState.split(',');
            if (!currentStateArray.includes(href)) {
                currentStateArray.push(href);
                localStorage.setItem('menuState', currentStateArray.join(','));
            }
        } else {

            localStorage.setItem('menuState', href);
        }
    } else {

        var currentState = localStorage.getItem('menuState');
        var currentStateArray = currentState.split(',');
        var index = currentStateArray.indexOf(href);
        if (index !== -1) {
            currentStateArray.splice(index, 1);
            localStorage.setItem('menuState', currentStateArray.join(','));
        }
    }

    $(this).next('.navpanel-submenu').slideToggle();
});



});
