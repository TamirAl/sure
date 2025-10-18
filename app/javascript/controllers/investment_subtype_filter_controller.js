// Investment Subtype Filter Stimulus Controller
// Lightweight controller for filtering subtypes within grouped selects
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { country: String }

  connect() {
    this.filterOptions()
  }

  countryValueChanged() {
    this.filterOptions()
  }

  filterOptions() {
    if (!this.countryValue) return

    const select = this.element.tagName === 'SELECT' ? this.element : this.element.querySelector('select')
    if (!select) return

    Array.from(select.querySelectorAll('optgroup')).forEach(optgroup => {
      const shouldShow = optgroup.label.includes(this.countryValue) || 
                        optgroup.label.includes('International')
      optgroup.style.display = shouldShow ? '' : 'none'
    })
  }
}