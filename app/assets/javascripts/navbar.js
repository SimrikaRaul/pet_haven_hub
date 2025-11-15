function initNavbar() {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.getElementById('primary-menu');

  if (toggle && menu) {
    toggle.addEventListener('click', () => {
      const visible = menu.getAttribute('data-visible') === 'true';
      menu.setAttribute('data-visible', (!visible).toString());
      toggle.setAttribute('aria-expanded', (!visible).toString());
    });
  }

  // Dropdown toggles
  document.querySelectorAll('#primary-menu .menu-item').forEach((item) => {
    const title = item.querySelector('.menu-title');
    const submenu = item.querySelector('.submenu');
    if (!title || !submenu) return;

    // click/tap to toggle on small screens
    title.addEventListener('click', (e) => {
      const isOpen = item.classList.contains('open');
      item.classList.toggle('open', !isOpen);
      const expanded = (!isOpen).toString();
      item.setAttribute('aria-expanded', expanded);
      title.setAttribute('aria-expanded', expanded);
    });

    // keyboard accessibility
    title.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        title.click();
      }
      if (e.key === 'Escape') {
        item.classList.remove('open');
        item.setAttribute('aria-expanded', 'false');
        title.setAttribute('aria-expanded', 'false');
      }
    });
  });

  // close dropdowns on outside click
  document.addEventListener('click', (e) => {
    const isInside = e.target.closest && e.target.closest('#primary-menu');
    if (!isInside) {
      document.querySelectorAll('#primary-menu .menu-item.open').forEach((it) => {
        it.classList.remove('open');
        it.setAttribute('aria-expanded', 'false');
        const title = it.querySelector('.menu-title');
        if (title) title.setAttribute('aria-expanded', 'false');
      });
    }
  });
}

// Initialize on Turbolinks / Turbo load and fallback to DOMContentLoaded
document.addEventListener('turbo:load', initNavbar);
document.addEventListener('DOMContentLoaded', initNavbar);

export default initNavbar;
