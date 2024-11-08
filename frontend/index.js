import { backend } from "declarations/backend";

const loader = document.getElementById("loader");
const crystalContainer = document.getElementById("crystalContainer");
const createButton = document.getElementById("createCrystal");

// Show/hide loader
const toggleLoader = (show) => {
    loader.classList.toggle("d-none", !show);
};

// Create crystal element
const createCrystalElement = (crystal) => {
    const col = document.createElement("div");
    col.className = "col-md-4 col-lg-3";
    col.innerHTML = `
        <div class="crystal-card">
            <div class="crystal-display" style="--crystal-color: ${crystal.color}">
                <div class="crystal pattern-${crystal.pattern}" 
                     style="transform: scale(${crystal.size / 100})">
                </div>
            </div>
            <div class="crystal-info">
                <div class="progress mb-2">
                    <div class="progress-bar" role="progressbar" 
                         style="width: ${crystal.size}%" 
                         aria-valuenow="${crystal.size}" 
                         aria-valuemin="0" 
                         aria-valuemax="100">
                        ${Math.round(crystal.size)}%
                    </div>
                </div>
                <button class="btn btn-sm ${crystal.growing ? 'btn-danger' : 'btn-success'}"
                        data-id="${crystal.id}">
                    ${crystal.growing ? 'Pause Growth' : 'Resume Growth'}
                </button>
            </div>
        </div>
    `;

    const toggleButton = col.querySelector('button');
    toggleButton.addEventListener('click', async () => {
        toggleLoader(true);
        await backend.toggleGrowth(crystal.id);
        toggleLoader(false);
    });

    return col;
};

// Update crystal display
const updateCrystals = async () => {
    const crystals = await backend.getCrystals();
    crystalContainer.innerHTML = '';
    crystals.forEach(crystal => {
        crystalContainer.appendChild(createCrystalElement(crystal));
    });
};

// Create new crystal
createButton.addEventListener("click", async () => {
    toggleLoader(true);
    await backend.createCrystal();
    await updateCrystals();
    toggleLoader(false);
});

// Update display periodically
setInterval(updateCrystals, 1000);

// Initial load
updateCrystals();
