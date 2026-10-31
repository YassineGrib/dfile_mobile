// IntersectionObserver scroll entry & minimalist accordion controller
document.addEventListener('DOMContentLoaded', () => {
  const els = document.querySelectorAll('.reveal');
  if ('IntersectionObserver' in window) {
    const io = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            entry.target.classList.add('is-visible');
            io.unobserve(entry.target);
          }
        }
      },
      { threshold: 0.08, rootMargin: '0px 0px -24px 0px' }
    );
    els.forEach((el) => io.observe(el));
  } else {
    els.forEach((el) => el.classList.add('is-visible'));
  }

  document.querySelectorAll('.accordion-trigger').forEach((btn) => {
    btn.addEventListener('click', () => {
      const item = btn.closest('.accordion-item');
      const icon = btn.querySelector('.accordion-icon');
      const open = item.getAttribute('data-open') === 'true';
      item.setAttribute('data-open', open ? 'false' : 'true');
      btn.setAttribute('aria-expanded', open ? 'false' : 'true');
      if (icon) icon.textContent = open ? '+' : '-';
    });
  });

  const delForm = document.getElementById('deletion-request-form');
  if (delForm) {
    delForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const email = document.getElementById('req-email').value.trim();
      const scope = document.getElementById('req-scope').value;
      const notes = document.getElementById('req-notes').value.trim();
      const subject = encodeURIComponent(`Ledgo Account Deletion Request (${email})`);
      const body = encodeURIComponent(
        `Application: Ledgo: Freelance Ledger (com.dfile.dfile_mobile)\n` +
        `Account Email: ${email}\n` +
        `Request Scope: ${scope}\n` +
        `Additional Notes: ${notes || 'None'}\n\n` +
        `Please permanently erase my account and associated cloud workspace records.`
      );
      const statusEl = document.getElementById('req-status');
      if (statusEl) {
        statusEl.hidden = false;
      }
      window.location.href = `mailto:gribyassine@gmail.com?subject=${subject}&body=${body}`;
    });
  }
});

