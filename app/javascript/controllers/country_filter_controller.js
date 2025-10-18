// Country Filter Stimulus Controller
// Handles country-based filtering of account lists
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["accountsGrid", "loadingState"]

  connect() {
    // Controller is connected and ready
    console.log("Country filter controller connected")
  }

  filterAccounts(event) {
    // This handles the navigation - the server handles the actual filtering
    // But we can add some client-side enhancements here
    
    // Show loading state for better UX
    if (this.hasLoadingStateTarget && this.hasAccountsGridTarget) {
      this.showLoadingState()
      
      // Let the navigation happen, then hide loading state after a short delay
      setTimeout(() => {
        this.hideLoadingState()
      }, 500)
    }
  }

  showLoadingState() {
    if (this.hasAccountsGridTarget) {
      this.accountsGridTarget.classList.add('hidden')
    }
    if (this.hasLoadingStateTarget) {
      this.loadingStateTarget.classList.remove('hidden')
    }
  }

  hideLoadingState() {
    if (this.hasLoadingStateTarget) {
      this.loadingStateTarget.classList.add('hidden')
    }
    if (this.hasAccountsGridTarget) {
      this.accountsGridTarget.classList.remove('hidden')
    }
  }

  // Method for future AJAX filtering implementation
  async filterAccountsAjax(country) {
    try {
      this.showLoadingState()
      
      const response = await fetch(`${window.location.pathname}?country_filter=${country}`, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      
      if (response.ok) {
        const html = await response.text()
        // Update the accounts grid with new content
        // This would require Turbo frames or similar for partial updates
      }
    } catch (error) {
      console.error('Failed to filter accounts:', error)
    } finally {
      this.hideLoadingState()
    }
  }
}