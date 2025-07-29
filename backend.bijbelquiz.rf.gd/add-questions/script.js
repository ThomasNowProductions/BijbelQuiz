const form = document.getElementById('questionForm');
const dynamicFields = document.getElementById('dynamicFields');
const preview = document.getElementById('preview');
const downloadBtn = document.getElementById('downloadBtn');

// Declare questions array for use throughout the script
let questions = [];

// Removed: categories, categoryTranslations, and all related logic for category selection and rendering

// Toast utility
function showToast(message, isError = false) {
  let toast = document.createElement('div');
  toast.className = 'toast' + (isError ? ' error' : '');
  toast.setAttribute('role', 'alert');
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => { toast.classList.add('show'); }, 10);
  setTimeout(() => { toast.classList.remove('show'); setTimeout(() => toast.remove(), 400); }, 2200);
}

// Local backup helpers
function saveBackup() {
  localStorage.setItem('bijbelquiz_questions', JSON.stringify(questions));
}
function restoreBackup() {
  const data = localStorage.getItem('bijbelquiz_questions');
  if (data) {
    questions = JSON.parse(data);
    updatePreview(true);
    showToast('Backup hersteld!');
  } else {
    showToast('Geen backup gevonden.', true);
  }
}
function clearAll() {
  questions = [];
  saveBackup();
  updatePreview(true);
  showToast('Alle vragen verwijderd!');
}

// Removed categories, categoryTranslations, searchBox, filteredCategories, renderCategoryCheckboxes, and all related logic
// Remove all code that references categoriesListDiv, searchBox, and category checkboxes

// Populate the categories-list div with checkboxes
// function renderCategoryCheckboxes() {
//   categoriesListDiv.innerHTML = '';
//   filteredCategories.forEach((cat, i) => {
//     const id = `cat_${i}`;
//     const wrapper = document.createElement('div');
//     wrapper.style.display = 'flex';
//     wrapper.style.alignItems = 'center';
//     wrapper.style.gap = '6px';
//     const checkbox = document.createElement('input');
//     checkbox.type = 'checkbox';
//     checkbox.id = id;
//     checkbox.name = 'categories';
//     checkbox.value = cat;
//     const label = document.createElement('label');
//     label.setAttribute('for', id);
//     label.textContent = categoryTranslations[cat] || cat;
//     wrapper.appendChild(checkbox);
//     wrapper.appendChild(label);
//     categoriesListDiv.appendChild(wrapper);
//   });
// }

// searchBox.addEventListener('input', function() {
//   const query = searchBox.value.trim().toLowerCase();
//   filteredCategories = categories.filter(cat => {
//     const dutch = (categoryTranslations[cat] || '').toLowerCase();
//     return cat.toLowerCase().includes(query) || dutch.includes(query);
//   });
//   renderCategoryCheckboxes();
// });

window.addEventListener('DOMContentLoaded', () => {
  // renderCategoryCheckboxes(); // This line is removed
  if (localStorage.getItem('bijbelquiz_questions')) {
    restoreBackup();
    document.getElementById('restoreBtn').style.display = '';
    document.getElementById('clearBtn').style.display = '';
  }
});

function renderFields(type) {
  // Always clear previous dynamic fields and their values
  dynamicFields.innerHTML = '';
  let html = '';
  if (type === 'mc') {
    html += `<label for="vraag">Vraag:</label>\n`;
    html += `<input type="text" id="vraag" name="vraag" required aria-required="true" placeholder="Typ hier de vraag...">\n`;
    html += `<label for="juisteAntwoord">Juiste antwoord:</label>\n`;
    html += `<input type="text" id="juisteAntwoord" name="juisteAntwoord" required aria-required="true" placeholder="Typ hier het juiste antwoord...">\n`;
    html += `<label>Foute antwoorden:</label>\n`;
    html += `<input type="text" id="fouteAntwoord1" name="fouteAntwoord1" required placeholder="Typ hier een fout antwoord..." aria-required="true">\n`;
    html += `<input type="text" id="fouteAntwoord2" name="fouteAntwoord2" required placeholder="Typ here een fout antwoord..." aria-required="true">\n`;
    html += `<input type="text" id="fouteAntwoord3" name="fouteAntwoord3" required placeholder="Typ hier een fout antwoord..." aria-required="true">\n`;
  } else if (type === 'fitb') {
    html += `<label for="vraag">Vraag (gebruik _____ voor het invulveld):</label>\n`;
    html += `<input type="text" id="vraag" name="vraag" required placeholder="Bijv. Mozes leidde het volk _____ uit Egypte" aria-required="true">\n`;
    html += `<label for="juisteAntwoord">Juiste antwoord:</label>\n`;
    html += `<input type="text" id="juisteAntwoord" name="juisteAntwoord" required aria-required="true" placeholder="Typ hier het juiste antwoord...">\n`;
    html += `<label>Foute antwoorden:</label>\n`;
    html += `<input type="text" id="fouteAntwoord1" name="fouteAntwoord1" required placeholder="Typ hier een fout antwoord..." aria-required="true">\n`;
    html += `<input type="text" id="fouteAntwoord2" name="fouteAntwoord2" required placeholder="Typ here een fout antwoord..." aria-required="true">\n`;
    html += `<input type="text" id="fouteAntwoord3" name="fouteAntwoord3" required placeholder="Typ hier een fout antwoord..." aria-required="true">\n`;
  } else if (type === 'tf') {
    html += `<label for="vraag">Stelling:</label>\n`;
    html += `<input type="text" id="vraag" name="vraag" required aria-required="true" placeholder="Typ hier de stelling...">\n`;
    html += `<label for="juisteAntwoord">Is dit waar?</label>\n`;
    html += `<select id="juisteAntwoord" name="juisteAntwoord"><option value="Waar">Waar</option><option value="Niet waar">Niet waar</option></select>\n`;
  }
  dynamicFields.innerHTML = html;
}

form.type.addEventListener('change', e => {
  // Only reset dynamic fields, not the whole form
  renderFields(e.target.value);
});

// Initial render
renderFields(form.type.value);

// In form submit, use checked checkboxes for categories
form.addEventListener('submit', function(e) {
  e.preventDefault();
  const type = form.type.value;
  const vraag = form.querySelector('#vraag') ? form.querySelector('#vraag').value.trim() : '';
  const juisteAntwoord = form.querySelector('#juisteAntwoord') ? form.querySelector('#juisteAntwoord').value.trim() : '';
  const moeilijkheidsgraad = Number(form.difficulty.value);
  // Always set categories to empty array
  const categories = [];
  let questionObj = {
    vraag,
    juisteAntwoord,
    moeilijkheidsgraad,
    type,
    categories,
    fouteAntwoorden: [] // Always present for all types
  };
  if (type === 'mc' || type === 'fitb') {
    const fouteAntwoorden = [
      form.querySelector('#fouteAntwoord1').value.trim(),
      form.querySelector('#fouteAntwoord2').value.trim(),
      form.querySelector('#fouteAntwoord3').value.trim()
    ];
    questionObj.fouteAntwoorden = fouteAntwoorden;
    // Validation for MC and FITB
    if (!vraag || !juisteAntwoord || fouteAntwoorden.some(f => !f)) {
      showToast('Vul alle verplichte velden in.', true);
      return;
    }
  } else if (type === 'tf') {
    questionObj.juisteAntwoord = juisteAntwoord === 'Waar' ? 'Waar' : 'Niet waar';
    questionObj.fouteAntwoorden = [juisteAntwoord === 'Waar' ? 'Niet waar' : 'Waar'];
    // Validation for TF
    if (!vraag || !juisteAntwoord) {
      showToast('Vul alle verplichte velden in.', true);
      return;
    }
  }
  questions.push(questionObj);
  saveBackup();
  updatePreview();
  showToast('Vraag toegevoegd!');
  form.reset();
  renderFields(type); // Reset dynamic fields
});

function updatePreview(animate = false) {
  // Update question count box only
  const countBox = document.getElementById('questionCountBox');
  if (questions.length > 0) {
    countBox.textContent = `Aantal vragen in lijst: ${questions.length}`;
    countBox.style.display = '';
  } else {
    countBox.style.display = 'none';
  }
}

// Modal confirmation for clear all
const clearBtn = document.getElementById('clearBtn');
const confirmModal = document.getElementById('confirmModal');
const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');

clearBtn.addEventListener('click', function() {
  confirmModal.style.display = 'flex';
});

cancelDeleteBtn.addEventListener('click', function() {
  confirmModal.style.display = 'none';
});

confirmDeleteBtn.addEventListener('click', function() {
  confirmModal.style.display = 'none';
  questions = [];
  saveBackup();
  updatePreview(true);
  showToast('Alle vragen verwijderd!');
});

downloadBtn.addEventListener('click', function() {
  if (questions.length === 0) {
    showToast('Geen vragen toegevoegd!', true);
    return;
  }
  const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(questions, null, 2));
  const dlAnchor = document.createElement('a');
  dlAnchor.setAttribute("href", dataStr);
  dlAnchor.setAttribute("download", "nieuwe_vragen.json");
  document.body.appendChild(dlAnchor);
  dlAnchor.click();
  dlAnchor.remove();
  showToast('Download gestart!');
  // Clear questions, backup, and preview after export
  questions = [];
  saveBackup();
  updatePreview(true);
});

document.getElementById('restoreBtn').addEventListener('click', restoreBackup); 