function dismissToast(toast) {
  toast.classList.add('toast-hiding');
  toast.addEventListener('transitionend', function handler() {
    toast.removeEventListener('transitionend', handler);
    toast.remove();

    // Remove container if empty
    var container = document.querySelector('.toast-container');
    if (container && container.children.length === 0) {
      container.remove();
    }
  });
}

function initFlashMessages() {
  document.querySelectorAll('.toast-message').forEach(function (toast) {
    // Skip if already initialized
    if (toast.dataset.initialized) return;
    toast.dataset.initialized = 'true';

    // Auto-dismiss after 10 seconds
    var timer = setTimeout(function () {
      dismissToast(toast);
    }, 10000);

    // Manual close button
    var closeBtn = toast.querySelector('.toast-close');
    if (closeBtn) {
      closeBtn.addEventListener('click', function () {
        clearTimeout(timer);
        dismissToast(toast);
      });
    }
  });
}

document.addEventListener('DOMContentLoaded', initFlashMessages);
document.addEventListener('turbo:load', initFlashMessages);
document.addEventListener('turbo:render', initFlashMessages);
