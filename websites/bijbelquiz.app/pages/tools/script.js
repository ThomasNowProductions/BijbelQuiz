const form = document.getElementById('questionForm');
const dynamicFields = document.getElementById('dynamicFields');
const downloadBtn = document.getElementById('downloadBtn');

// Declare questions array for use throughout the script
let questions = [];

// Categories list from categories.json
const categoriesList = [
  "Genesis", "Exodus", "Leviticus", "Numeri", "Deuteronomium",
  "Jozua", "Richteren", "Ruth", "1 Samuël", "2 Samuël",
  "1 Koningen", "2 Koningen", "1 Kronieken", "2 Kronieken",
  "Ezra", "Nehemia", "Esther", "Job", "Psalmen", "Spreuken",
  "Prediker", "Hooglied", "Jesaja", "Jeremia", "Klaagliederen",
  "Ezechiël", "Daniël", "Hosea", "Joël", "Amos", "Obadja",
  "Jona", "Micha", "Nahum", "Habakuk", "Zefanja", "Haggai",
  "Zacharia", "Maleachi", "Matteüs", "Marcus", "Lucas",
  "Johannes", "Handelingen", "Romeinen", "1 Korintiërs",
  "2 Korintiërs", "Galaten", "Efeziërs", "Filippenzen",
  "Kolossenzen", "1 Tessalonicenzen", "2 Tessalonicenzen",
  "1 Timoteüs", "2 Timoteüs", "Titus", "Filemon", "Hebreeën",
  "Jakobus", "1 Petrus", "2 Petrus", "1 Johannes", "2 Johannes",
  "3 Johannes", "Judas", "Openbaring", "Kerst", "Pasen",
  "Pinksteren", "Hemelvaart", "Goede Vrijdag", "Stille Zaterdag",
  "Paasmaandag", "Pinkstermaandag"
];

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

// Function to save the last selected question type
function saveLastQuestionType(type) {
  localStorage.setItem('bijbelquiz_last_type', type);
}

// Generate the next question ID based on existing questions
function getNextQuestionId() {
  if (questions.length === 0) {
    return '000001';
  }
  // Find the highest ID number
  let maxId = 0;
  questions.forEach(q => {
    if (q.id) {
      const idNum = parseInt(q.id, 10);
      if (!isNaN(idNum) && idNum > maxId) {
        maxId = idNum;
      }
    }
  });
  // Generate next ID with leading zeros
  const nextId = (maxId + 1).toString().padStart(6, '0');
  return nextId;
}

// Render category checkboxes
function renderCategories() {
  let html = '<label>Categorieën (optioneel):</label>';
  html += '<div class="categories-container">';
  categoriesList.forEach(cat => {
    const catId = 'cat_' + cat.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '');
    html += `<div class="category-item">`;
    html += `<input type="checkbox" id="${catId}" name="categories" value="${cat}">`;
    html += `<label for="${catId}">${cat}</label>`;
    html += `</div>`;
  });
  html += '</div>';
  return html;
}

window.addEventListener('DOMContentLoaded', () => {
  // Restore last selected question type
  const lastType = localStorage.getItem('bijbelquiz_last_type');
  if (lastType) {
    const typeSelect = document.getElementById('type');
    typeSelect.value = lastType;
    renderFields(lastType);
  }

  // Restore questions if they exist
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
    html += `<label for="vraag">Vraag:</label>
`;
    html += `<input type="text" id="vraag" name="vraag" required aria-required="true" placeholder="Typ hier de vraag...">
`;
    html += `<label for="juisteAntwoord">Juiste antwoord:</label>
`;
    html += `<input type="text" id="juisteAntwoord" name="juisteAntwoord" required aria-required="true" placeholder="Typ hier het juiste antwoord...">
`;
    html += `<label>Foute antwoorden:</label>
`;
    html += `<input type="text" id="fouteAntwoord1" name="fouteAntwoord1" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<input type="text" id="fouteAntwoord2" name="fouteAntwoord2" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<input type="text" id="fouteAntwoord3" name="fouteAntwoord3" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<label for="biblicalReference">Bijbelreferentie (optioneel):</label>
`;
    html += `<input type="text" id="biblicalReference" name="biblicalReference" placeholder="Bijv. Genesis 1:1">
`;
    html += renderCategories();
  } else if (type === 'fitb') {
    html += `<label for="vraag">Vraag (gebruik _____ voor het invulveld):</label>
`;
    html += `<input type="text" id="vraag" name="vraag" required placeholder="Bijv. Mozes leidde het volk _____ uit Egypte" aria-required="true">
`;
    html += `<label for="juisteAntwoord">Juiste antwoord:</label>
`;
    html += `<input type="text" id="juisteAntwoord" name="juisteAntwoord" required aria-required="true" placeholder="Typ hier het juiste antwoord...">
`;
    html += `<label>Foute antwoorden:</label>
`;
    html += `<input type="text" id="fouteAntwoord1" name="fouteAntwoord1" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<input type="text" id="fouteAntwoord2" name="fouteAntwoord2" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<input type="text" id="fouteAntwoord3" name="fouteAntwoord3" required placeholder="Typ hier een fout antwoord..." aria-required="true">
`;
    html += `<label for="biblicalReference">Bijbelreferentie (optioneel):</label>
`;
    html += `<input type="text" id="biblicalReference" name="biblicalReference" placeholder="Bijv. Exodus 3:14">
`;
    html += renderCategories();
  } else if (type === 'tf') {
    html += `<label for="vraag">Stelling:</label>
`;
    html += `<input type="text" id="vraag" name="vraag" required aria-required="true" placeholder="Typ hier de stelling...">
`;
    html += `<label for="juisteAntwoord">Is dit waar?</label>
`;
    html += `<select id="juisteAntwoord" name="juisteAntwoord"><option value="Waar">Waar</option><option value="Niet waar">Niet waar</option></select>
`;
    html += `<label for="biblicalReference">Bijbelreferentie (optioneel):</label>
`;
    html += `<input type="text" id="biblicalReference" name="biblicalReference" placeholder="Bijv. Johannes 3:16">
`;
    html += renderCategories();
  }
  dynamicFields.innerHTML = html;
}

form.type.addEventListener('change', e => {
  // Only reset dynamic fields, not the whole form
  const selectedType = e.target.value;
  renderFields(selectedType);
  saveLastQuestionType(selectedType);
});

// Initial render
renderFields(form.type.value);

// Collect selected categories from checkboxes
function getSelectedCategories() {
  const checkboxes = form.querySelectorAll('input[name="categories"]:checked');
  return Array.from(checkboxes).map(cb => cb.value);
}

// In form submit, use checked checkboxes for categories
form.addEventListener('submit', function(e) {
  e.preventDefault();
  const type = form.type.value;
  const vraag = form.querySelector('#vraag') ? form.querySelector('#vraag').value.trim() : '';
  const juisteAntwoord = form.querySelector('#juisteAntwoord') ? form.querySelector('#juisteAntwoord').value.trim() : '';
  const moeilijkheidsgraad = Number(form.difficulty.value);
  const biblicalReference = form.querySelector('#biblicalReference') ? form.querySelector('#biblicalReference').value.trim() : '';
  // Get selected categories from checkboxes
  const categories = getSelectedCategories();
  // Generate unique ID
  const id = getNextQuestionId();
  
  let questionObj = {
    vraag,
    juisteAntwoord,
    moeilijkheidsgraad,
    type,
    categories,
    biblicalReference: biblicalReference || null, // Set to null if empty
    fouteAntwoorden: [], // Always present for all types
    id
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
  showToast('Vraag toegevoegd! ID: ' + id);
  form.reset();
  form.type.value = type; // Keep the same question type selected
  saveLastQuestionType(type); // Save the type
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
