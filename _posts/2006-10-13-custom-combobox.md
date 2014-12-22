---
layout: post
---
This is another forum request.  I've seen multiple requests from users who are looking to customize the drop down window for the ComboBox control.  There is no builtin way to do this with the existing control.  Instead you must create a custom solution.

Start by adding a new UserControl to your windows application or library project.  Have it inherit from ComboBox and call it CustomComboBox.

This ComboBox will display a user provided control for the drop down window.  We will be using an instance of System.Windows.Form (named m_form) to replace the drop down window.  The idea is to have the control to essentially float below the ComboBox much like the drop down window does today.  To do this we need to custom the Form to not show up in the task bar and to not have a titlebar or default buttons.

We also need to prevent the ComboBox from droping down the builtin window.  There is no way to actually stop the ComboBox from dropping down the window.  Instead we need to make it appear that the drop down didn't display by setting it's height to 1 pixel.

To make the logic a bit easier, we will also provide a default empty control to be displayed when the drop down is expanded

Here is the full text of the constructor used to initialize the CustomComboBox

``` vbnet
Public Sub New()

        ' This call is required by the Windows Form Designer.
        InitializeComponent()

        ' Setup the form to display the control
        m_form = New Form()
        m_form.StartPosition = FormStartPosition.Manual
        m_form.FormBorderStyle = FormBorderStyle.None
        m_form.Hide()
        m_form.ShowInTaskbar = False

        Me.Control = New Control()   ' Default Control
        m_dropDownHeight = Me.DropDownHeight
        Me.DropDownHeight = 1       ' Prevent the DropDown from showing
    End Sub
```

The next step is to have the form display in the proper place when the drop down button is hit. To do this we override the OnDropDown() method and add the display logic there.

``` vbnet
Protected Overrides Sub OnDropDown(ByVal e As System.EventArgs)
    MyBase.OnDropDown(e)

    If Not m_form.Visible Then
        DisplayControl()
    End If

    Me.DroppedDown = False
End Sub

Private Sub DisplayControl()
    Dim loc As Point = Me.PointToScreen(Point.Empty)
    loc.Y += Me.Height

    m_form.Location = loc
    m_form.Show()
End Sub
```


The last item left is to add a property for the user to set the custom control to display. To be flexible we will allow instances of Control. It will be docked in the form. We also need to listen to the LostFocus event on the control. This is the key for us to hide the form like when the user clicks away from the normal ComboBox.

``` vbnet
Public Property Control() As Control
    Get
        Return m_control
    End Get
    Set(ByVal value As Control)
        If Not m_control Is Nothing Then
            m_form.Controls.Remove(m_control)
            RemoveHandler m_control.LostFocus, AddressOf Me.OnControlLostFocus
        End If

        m_control = value
        m_control.Dock = DockStyle.Fill
        AddHandler m_control.LostFocus, AddressOf Me.OnControlLostFocus
        m_form.Controls.Add(m_control)
    End Set
End Property

Private Sub OnControlLostFocus(ByVal sender As Object, ByVal e As EventArgs)
    m_form.Hide()
End Sub
```

    

