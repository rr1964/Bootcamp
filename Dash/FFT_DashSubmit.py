
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State
import plotly.graph_objects as go
import plotly.express as px
import numpy as np
import pandas as pd


app = dash.Dash(__name__)

app.layout = html.Div( className='row', style={'display': 'flex'}, children=[

    html.Div(children = [
        html.H3('Hidden Frequency'),
        dcc.Checklist(id="rand",
                      options=[
                        {'label': 'Insert hidden frequencies?', 'value': 'hidden'}
                        # Only a single checkbox. Add others as necessary.
                        ],
                      value=['hidden']
        ),
        html.Br(),
        dcc.Input(
                id="numFreq", type="number", placeholder="# of hidden frequencies",
                min=1, max=20, step=1,style={'width': '90%'}
            ),
        html.Br(),
        html.Br(),
        html.H3('First Frequency'),
        dcc.Input(
                id="freq1", type="number", placeholder="First Frequency",
                min=10, max=100, step=0.1,style={'width': '90%'}
            ),
        html.H3('Second Frequency'),
        dcc.Input(
                id="freq2", type="number", placeholder="Second Frequency",
                min=10, max=100, step=0.1, style={'width': '90%'}
            ),
        html.Br(),
        html.Br(),
        html.Button(id='submit-button', n_clicks=0, children='Submit')
        ]),

    html.Div([dcc.Graph(id="graph", style={'display': 'inline-block'})])



    ])


@app.callback(
    Output("graph", "figure"),
    Input("submit-button", "n_clicks"),
    [State("freq1", "value"), State("freq2", "value"), State("rand", "value"),  State("numFreq", "value")])
def calc_FFT(n_clicks, f1, f2, hidden, numFreq):
    N = 600
    # sample spacing
    T = 1.0 / 200.0
    x = np.linspace(0.0, N * T, N, endpoint=False)

    if f1 is None or f2 is None or numFreq is None:
        y = np.zeros(N)

    elif hidden:
        fh = [np.random.poisson(4*f + 5, 1) for f in range(numFreq)]
        additional = [np.abs(np.random.chisquare(1)) * np.sin(phi * 2.0 * np.pi * x) for phi in fh]
        y = np.sin(f1 * 2.0 * np.pi * x) + 0.5 * np.sin(f2 * 2.0 * np.pi * x) + np.sum(additional, axis=0)

    else:
        y = np.sin(f1 * 2.0 * np.pi * x) + 0.5 * np.sin(f2 * 2.0 * np.pi * x)

    # Only look at first half. FFT is symmetric on real valued input.
    xf = np.fft.fftfreq(N, T)[:N // 2]
    yf = np.fft.fft(y)[:N // 2]

    fig = build_figure(xf, yf)

    return fig


# ############ HELPER FUNCTIONS ############
# Not necessary here. But helpful.
def build_figure(xf, yf):
    N = len(yf)
    fig = go.Figure()
    fig.add_trace(go.Scatter(x=xf, y=2.0 / N * np.abs(yf), mode='lines', name='FFT'))

    fig.update_layout(title='(Discrete) FFT of Sinusoud Signal ',
                      xaxis_title='Frequency',
                      yaxis_title='FFT')

    return fig


app.run_server(debug=True)