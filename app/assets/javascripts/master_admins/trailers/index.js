const form = (() => {
  const PLAN_KINDS = ['fundamental', 'expanded', 'complete', 'premium'];

  const featuresForKind = kind => {
    return $('.js-plan-features').data(kind) || [];
  }

  const kindForFeatures = features => {
    const kind = PLAN_KINDS.find(kind => {
      const kindFeatures = featuresForKind(kind);
      return features.every(f => kindFeatures.includes(f)) && kindFeatures.length == features.length;
    });

    return kind || 'custom';
  }

  const checkFeatures = kind => {
    const features       = featuresForKind(kind);
    const $featureBoxes  = $('.js-feature-check');
    const $filteredBoxes = $featureBoxes.filter((_, check) => features.includes(check.value));

    $featureBoxes.prop('checked', false);
    $filteredBoxes.prop('checked', true);
  }

  const selectKind = kind => {
    $('.js-feature-kind').val(kind).prop('selected', true);
  }

  const setEventListeners = () => {
    $('.js-feature-kind').on('change', (event) => {
      const $option = $(event.currentTarget);
      checkFeatures($option.val());
    });

    $('.js-feature-check').on('click', event => {
      const checkedFeatures =
        $('.js-feature-check')
          .filter((_, check) => check.checked)
          .map((_, check) => check.value)
          .get();

      const kind = kindForFeatures(checkedFeatures);
      selectKind(kind);
    });
  }

  const init = () => {
    setEventListeners();
  }

  return { init: init }
})();

window.admin = window.admin || {};
window.admin.trailers = {
  ...window.admin.trailers,
  form: form,
};
