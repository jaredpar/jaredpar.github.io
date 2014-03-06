---
layout: post
---
ComboBox has a lot of helpful properties that allow you to get access to items selected by the Control.  The problem is knowing which one is best in which scenario.  The documentation is not 100% clear on what the values will be in various situtations.  The most important factor to know is whether or not you are DataBinding in the ComboBox.

**DataBinding Case**

In this case the properties will have the following values

  * SelectedItem - For gets this will return the actual object in the DataSource that is being displayed in the ComboBox.  For sets if the value exists in the DataSource, it will be selected, otherwise the operation will complete without an exception but won't actually do anything.
  * SelectedValue - This property depends on the value of ValueMember. 

If the property ValueMember is not Nothing the ComboBox will look for a member on SelectedItem with the name specified in ValueMember and return that.  This is also the value displayed in the ComboBox.

If the property ValueMember is Nothing, then the SelectedValue will return .ToString() on the SelectedItem

  * SelectedIndex - Index of SelectedItem in the DataSource 

**Non-DataBinding Case**

  * SelectedItem - Gets and Sets both go to the currently selected object from the Items collection
  * SelectedValue - Will be Nothing/null 
  * SelectedIndex - Index in the Items collection of the SelectedItem



