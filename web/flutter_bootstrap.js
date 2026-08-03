// Flutter registra por defecto un service worker que guarda la app en el
// navegador. El efecto secundario es que, tras cada despliegue, la gente sigue
// viendo la versión anterior hasta que borra los datos del sitio a mano — y en
// Safari puede quedarse pegada durante días.
//
// Acá no se registra ninguno, y además se limpia el que haya quedado de
// instalaciones previas para que nadie se quede atrapado en una versión vieja.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations()
    .then(function (registros) { registros.forEach(function (r) { r.unregister(); }); })
    .catch(function () {});
}
if (window.caches) {
  caches.keys()
    .then(function (nombres) { nombres.forEach(function (n) { caches.delete(n); }); })
    .catch(function () {});
}

{{flutter_js}}
{{flutter_build_config}}

// Sin serviceWorkerSettings: el cargador no instala service worker.
_flutter.loader.load();
