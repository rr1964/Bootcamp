# Run this app with `python BoilerPlate.py` and
# visit http://127.0.0.1:8050/ in your web browser.

import dash
import dash_core_components as dcc
import dash_html_components as html


app = dash.Dash()


app.layout = html.Div(children=[
    html.H1(children='Hello Dash'),

    html.Div(children='''
        Dash boilerplate.
    '''),

])

if __name__ == '__main__':
    app.run_server(debug=True)
