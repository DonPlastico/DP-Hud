(function () {
  const odometer = document.querySelector(".odometer");
  const value = document.querySelector(".odometer-value");
  const unit = document.querySelector(".odometer-unit");

  // Configuración inicial
  odometer.style.display = "none";

  function elementPosition(position) {
    // Resetear estilos primero
    odometer.style.top = '';
    odometer.style.bottom = '';
    odometer.style.left = '';
    odometer.style.right = '';
    odometer.style.transform = '';

    switch (position) {
      case 'bottom-right':
        odometer.style.bottom = '.8vh';
        odometer.style.right = '55%';
        odometer.style.left = 'auto';
        odometer.style.transform = 'none';
        break;
      case 'bottom-left':
        odometer.style.bottom = '0.8vh';
        odometer.style.left = '1vw';
        odometer.style.transform = 'none';
        break;
      case 'top-right':
        odometer.style.top = '0.8vh';
        odometer.style.right = '1vw';
        odometer.style.left = 'auto';
        odometer.style.transform = 'none';
        break;
      case 'top-left':
        odometer.style.top = '0.8vh';
        odometer.style.left = '1vw';
        odometer.style.transform = 'none';
        break;
      case 'bottom-center':
        odometer.style.bottom = '0.8vh';
        odometer.style.left = '50%';
        odometer.style.transform = 'translateX(-50%)';
        break;
      case 'top-center':
        odometer.style.top = '0.8vh';
        odometer.style.left = '50%';
        odometer.style.transform = 'translateX(-50%)';
        break;
      default:
        odometer.style.bottom = '0.8vh';
        odometer.style.left = '50%';
        odometer.style.transform = 'translateX(-50%)';
        break;
    }
  }

  window.addEventListener("message", (evt) => {
    const { data } = evt;
    if (!data) return;

    const isVisible = odometer.style.display === "inline-flex";
    const displayValue = Math.floor(data.value * (data.unit === "miles" ? 0.621371 : 1)).toString();
    const displayUnit = data.unit === "miles" ? "Mi" : "Km";

    if (data.type === "show") {
      // Actualizar valores
      value.textContent = displayValue;
      unit.textContent = displayUnit;

      // Posicionamiento
      elementPosition(data.position || 'bottom-center');

      if (!isVisible) {
        // Mostrar con animación solo si estaba oculto
        odometer.style.display = "inline-flex";
        odometer.style.opacity = "0";
        odometer.style.animation = "none";
        void odometer.offsetWidth; // Trigger reflow
        odometer.style.animation = "carhud-enter 0.3s forwards";
        odometer.style.opacity = "1";
      } else {
        // Efecto de actualización para cambios de valor
        if (value.textContent !== displayValue || unit.textContent !== displayUnit) {
          odometer.classList.add("value-update");
          void odometer.offsetWidth;
          odometer.classList.remove("value-update");
        }
      }

    } else if (data.type === "hide" && isVisible) {
      // Ocultar con animación
      odometer.style.animation = "none";
      odometer.style.opacity = "0";
      setTimeout(() => {
        odometer.style.display = "none";
      }, 300);
    }
  });
})();