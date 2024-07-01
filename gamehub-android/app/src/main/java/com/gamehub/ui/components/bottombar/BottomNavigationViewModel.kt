package com.gamehub.ui.components.bottombar

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class BottomNavigationViewModel @Inject constructor() : ViewModel() {
    private val _selectedItem = MutableLiveData<Int>()
    val selectedItem: LiveData<Int> get() = _selectedItem

    init {
        _selectedItem.value = 0 // Default to Home
    }

    fun setSelectedItem(index: Int) {
        _selectedItem.value = index
    }
}