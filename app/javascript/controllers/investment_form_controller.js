// Investment Form Stimulus Controller
// Handles country filtering and real-time account information display
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["countryFilter", "subtypeSelect", "infoPanel", "countryFlag", "subtypeName", "taxBadge", "countryName"]
  static values = { 
    currentCountry: String,
    subtypeData: Object 
  }

  connect() {
    this.loadSubtypeData()
    this.updateSubtypeOptions()
  }

  async loadSubtypeData() {
    try {
      const response = await fetch('/api/v1/investments/subtype_data.json')
      if (response.ok) {
        this.subtypeDataValue = await response.json()
      }
    } catch (error) {
      console.error('Failed to load subtype data:', error)
      // Fallback to basic functionality without enhanced data
    }
  }

  filterByCountry() {
    const selectedCountry = this.countryFilterTarget.value
    this.currentCountryValue = selectedCountry
    this.updateSubtypeOptions()
  }

  updateSubtypeOptions() {
    const select = this.element.querySelector('select[name*="subtype"]')
    if (!select) return

    const currentCountry = this.currentCountryValue

    // Show/hide optgroups based on country filter
    Array.from(select.querySelectorAll('optgroup')).forEach(optgroup => {
      if (!currentCountry || optgroup.label.includes(currentCountry) || optgroup.label.includes('International')) {
        optgroup.style.display = ''
      } else {
        optgroup.style.display = 'none'
      }
    })
  }

  subtypeChanged() {
    const select = this.element.querySelector('select[name*="subtype"]')
    const selectedSubtype = select ? select.value : null
    
    if (selectedSubtype && this.subtypeDataValue) {
      this.showAccountInfo(selectedSubtype)
    } else {
      this.hideAccountInfo()
    }
  }

  showAccountInfo(subtype) {
    const data = this.subtypeDataValue[subtype]
    if (!data || !this.hasInfoPanelTarget) return

    this.infoPanelTarget.classList.remove('hidden')
    
    if (this.hasCountryFlagTarget) {
      this.countryFlagTarget.textContent = data.flag
    }
    
    if (this.hasSubtypeNameTarget) {
      this.subtypeNameTarget.textContent = data.long_name
    }
    
    if (this.hasCountryNameTarget) {
      this.countryNameTarget.textContent = data.country
    }
    
    // Update tax treatment badge
    if (this.hasTaxBadgeTarget && data.tax_treatment) {
      const badge = this.taxBadgeTarget
      badge.textContent = data.tax_treatment.text
      badge.className = `inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${data.tax_treatment.class}`
    }
  }

  hideAccountInfo() {
    if (this.hasInfoPanelTarget) {
      this.infoPanelTarget.classList.add('hidden')
    }
  }
}