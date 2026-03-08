function dismissToast(toast) {
  toast.classList.add('toast-hiding');
  toast.addEventListener('transitionend', function handler() {
    toast.removeEventListener('transitionend', handler);
    toast.remove();
  });
}

function initFlashMessages() {
  document.querySelectorAll('.toast-message').forEach(function (toast) {
    // Auto-dismiss after 5 seconds
    var timer = setTimeout(function () {
      dismissToast(toast);
    }, 5000);

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
