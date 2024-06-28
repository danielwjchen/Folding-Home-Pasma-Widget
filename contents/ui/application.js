const clientBaseUrl = "http://127.0.0.1:7396/api";
const projectBaseUrl = "https://stats.foldingathome.org/project";
const TIMEOUT = 1000;

function fetch(resource) {
	const url = (typeof resource === "string") ? resource : resource.url;
	const method = resource.method || "GET";
	return new Promise((resolve, reject) => {
		const request = new XMLHttpRequest();
		if (resource.headers) {
			Object.entries(resource).forEach(([key, value]) => {
				request.setRequestHeader(key, value);
			});
		}
		request.onreadystatechange = () => {
			if (request.readyState === XMLHttpRequest.DONE) {
				const response = {
					status: request.status,
					headers: request.getAllResponseHeaders(),
					contentType: request.responseType,
					content: request.response,
				};
				resolve(response);
			}
		}
		request.ontimeout = (event) => {
			reject(event);
		};
		request.onabort = (event) => {
			reject(event);
		};
		request.onerror = (event) => {
			reject(event);
		};
		request.open(method, url);
		request.send();
	});
}

function getUrl(path, queryParams) {
	const result = `${clientBaseUrl}/${path}`;
	if (queryParams) {
		const queryStrings = Object.entries(queryParams).map(([key, value]) => {
			return `${key}=${encodeURI(value)}`;
		});
		return `${result}?${queryStrings.join("&")}`;
	}
	return result;

}

function createSession() {
	const resource = {
		url: getUrl("session", { "_": Math.random() }),
		method: "PUT"
	};
	return new Promise((resolve, reject) => {

		fetch(resource).then(response => {
			Promise.all([
				fetch({
					url: getUrl("updates/set", {
						sid: response.content,
						update_id: 0,
						update_rate: 1,
						update_path: '/api/basic'
					}),
				}),
				fetch({
					url: getUrl("updates/set", {
						sid: response.content,
						update_id: 1,
						update_rate: 1,
						update_path: '/api/slots'
					}),
				})
			]).then(() => {
				// intentionally left blank
			}).catch(reason => {
				reject(reason);
			});
			resolve(response)
		})
	});

}

function getTimeoutPromise(timer, timeout) {
	return new Promise(resolve => {
		timer.setTimeout(() => {
			resolve();
		}, timeout);
	});
}

function getUpdates(timer, sid, callback) {
	const resource = {
		url: getUrl("updates", { sid: sid }),
	};
	Promise.all([
		fetch(resource).catch(reason => {
			console.debug(reason);
		}),
		getTimeoutPromise(timer, TIMEOUT),
	]).then(([response]) => {
		response.json = JSON.parse(response.content);
		callback(response);
		getUpdates(timer, sid, callback)
	});
}

function setRunsOnlyWhenIdle(sid, runsOnlyWhenIdle) {
	const resource = {
		url: getUrl("set", { sid: sid, idle: runsOnlyWhenIdle }),
	};
	fetch(resource).then(() => {
		// intentionally left blank
	}).catch(reason => {
		console.debug(reason);
	});
}

function setStopsAfterFinishingCurrentWorkUnit(sid, stopsAfterFinishingCurrentWorkUnit) {
	const resource = {
		url: getUrl("set", { sid: sid, finish: stopsAfterFinishingCurrentWorkUnit }),
	};
	fetch(resource).then(() => {
		// intentionally left blank
	}).catch(reason => {
		console.debug(reason);
	});
}

function getProjectInfo(projectId, version, callback) {
	const resource = {
		url: `${projectBaseUrl}?id=${projectId}&version=${version}`
	};
	fetch(resource).then((response) => {
		// result is actually in JSONP format and needs to be massaged
		// @see https://en.wikipedia.org/wiki/JSONP
		const indexOfFirstParenthesis = response.content.indexOf("(");
		const indexOfLastParenthesis = response.content.lastIndexOf(")");
		const parsed = response.content.substring(indexOfFirstParenthesis + 1, indexOfLastParenthesis);
		response.json = JSON.parse(parsed);
		callback(response);
	}).catch(reason => {
		console.debug(reason);
	});
}