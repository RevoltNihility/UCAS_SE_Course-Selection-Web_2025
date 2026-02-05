// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Flash消息自动关闭和手动关闭功能
document.addEventListener('turbo:load', () => {
  const flashMessages = document.querySelectorAll('[data-flash-message]');

  flashMessages.forEach((message) => {
    // 10秒后自动消失
    const autoCloseTimer = setTimeout(() => {
      closeFlashMessage(message);
    }, 10000);

    // 关闭按钮点击事件
    const closeButton = message.querySelector('[data-flash-close]');
    if (closeButton) {
      closeButton.addEventListener('click', () => {
        clearTimeout(autoCloseTimer);
        closeFlashMessage(message);
      });
    }
  });
});

function closeFlashMessage(message) {
  message.classList.add('fade-out');
  setTimeout(() => {
    message.remove();
  }, 300); // 等待动画完成
}
